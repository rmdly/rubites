# frozen_string_literal: true

require 'pty'
require 'io/console'
require_relative '../../lib/rubites/text'

module Rubites
  module Test
    # Reconstructs what a terminal would be showing, so the TUI can be
    # asserted on. Handles absolute cursor moves, clear-to-end-of-line and
    # clear-below. Colour is discarded.
    class VirtualScreen
      def initialize(rows, cols)
        @rows = rows
        @cols = cols
        @grid = Array.new(rows) { Array.new(cols, ' ') }
        @row = 0
        @col = 0
      end

      def feed(text)
        chars = text.each_char
        loop do
          char = chars.next
          case char
          when "\e" then escape(chars)
          when "\n" then (@row += 1) && (@col = 0)
          when "\r" then @col = 0
          else put(char)
          end
        end
      rescue StopIteration
        nil
      end

      def to_s
        @grid.map { |row| row.join.rstrip }.join("\n").sub(/(\n\s*)+\z/, '')
      end

      # Terminal column of the last `char` on each row that has one. Read from
      # the cell grid rather than #to_s, where the spacer cell after a
      # double-width character is empty and string indices would be short.
      def columns_of_last(char)
        @grid.filter_map { |row| row.rindex(char) }
      end

      private

        def escape(chars)
          return unless chars.next == '['

          params = +''
          final = nil
          loop do
            char = chars.next
            break (final = char) unless char.match?(/[0-9;?]/)

            params << char
          end

          case final
          when 'H' then move(params)
          when 'K' then clear_line
          when 'J' then clear_below
          end
        end

        def move(params)
          row, col = params.split(';').map(&:to_i)
          @row = [(row || 1) - 1, 0].max
          @col = [(col || 1) - 1, 0].max
        end

        def clear_line
          return if @row >= @rows

          (@col...@cols).each { |col| @grid[@row][col] = ' ' }
        end

        def clear_below
          ((@row + 1)...@rows).each { |row| @grid[row] = Array.new(@cols, ' ') }
        end

        # Double-width characters take two cells, as in a real terminal, so
        # mis-measured padding shows up as misalignment.
        def put(char)
          return if @row >= @rows || @col >= @cols

          @grid[@row][@col] = char
          width = char.match?(Rubites::Text::WIDE) ? 2 : 1
          @grid[@row][@col + 1] = '' if width == 2 && @col + 1 < @cols
          @col += width
        end
    end

    # Runs the real binary in a pty. Waits poll against a deadline rather than
    # sleeping for a fixed time.
    class Terminal
      ROOT = File.expand_path('../..', __dir__)
      TIMEOUT = 10

      attr_reader :exercises_dir, :state_dir

      def initialize(exercises_dir:, state_dir:, args: [], rows: 34, cols: 92)
        @exercises_dir = exercises_dir
        @state_dir = state_dir
        @screen = VirtualScreen.new(rows, cols)
        @buffer = +''.b

        env = { 'RUBITES_EXERCISES' => exercises_dir, 'RUBITES_STATE' => state_dir, 'USER' => 'tester' }
        @reader, @writer, @pid = PTY.spawn(env, File.join(ROOT, 'bin', 'rubites'), *args)
        @reader.winsize = [rows, cols]
      end

      def press(key)
        @writer.write(key)
        self
      rescue Errno::EIO, IOError
        self
      end

      def text
        pump(0.05)
        @screen.to_s
      end

      # Waits until the screen matches, and includes the whole screen in the
      # failure message if it never does.
      def wait_for(pattern, timeout: TIMEOUT)
        deadline = Time.now + timeout
        loop do
          pump(0.05)
          return @screen.to_s if @screen.to_s.match?(pattern)
          break if Time.now > deadline
        end

        raise "never matched #{pattern.inspect}. Screen was:\n\n#{@screen}"
      end

      def line_matching(pattern)
        text.lines.map(&:rstrip).find { |line| line.match?(pattern) }
      end

      def columns_of_last(char)
        pump(0.05)
        @screen.columns_of_last(char)
      end

      # Resizing the pty raises SIGWINCH in the child. The screen is rebuilt
      # because its geometry has changed.
      def resize(rows, cols)
        @screen = VirtualScreen.new(rows, cols)
        @reader.winsize = [rows, cols]
        self
      end

      def alive?
        Process.waitpid(@pid, Process::WNOHANG).nil?
      rescue Errno::ECHILD
        false
      end

      def wait_for_exit(timeout: 5)
        deadline = Time.now + timeout
        sleep 0.02 while alive? && Time.now < deadline
        !alive?
      end

      def close
        press('q')
        wait_for_exit(timeout: 2)
        Process.kill('KILL', @pid) if alive?
        Process.waitpid(@pid)
      rescue Errno::ESRCH, Errno::ECHILD
        nil
      ensure
        @reader.close unless @reader.closed?
        @writer.close unless @writer.closed?
      end

      private

        def pump(seconds)
          deadline = Time.now + seconds
          while Time.now < deadline
            remaining = deadline - Time.now
            break if remaining <= 0
            break unless @reader.wait_readable(remaining)

            begin
              @buffer << @reader.read_nonblock(65_536)
            rescue IO::WaitReadable
              next
            rescue IOError, Errno::EIO
              break
            end

            text, rest = decode(@buffer)
            @buffer = rest
            @screen.feed(text) unless text.empty?
          end
        end

        # read_nonblock can split a multi-byte character across chunks, so hold
        # the incomplete tail back until the rest arrives.
        def decode(buffer)
          candidate = buffer.dup.force_encoding('UTF-8')
          return [candidate, +''.b] if candidate.valid_encoding?

          (1..3).each do |trim|
            next if trim >= buffer.bytesize

            head = buffer.byteslice(0, buffer.bytesize - trim).force_encoding('UTF-8')
            return [head, buffer.byteslice(-trim, trim)] if head.valid_encoding?
          end

          ['', buffer]
        end
    end
  end
end
