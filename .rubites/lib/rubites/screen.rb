# frozen_string_literal: true

require 'io/console'

module Rubites
  # Raw ANSI rather than the curses gem. Escape codes are plain bytes on
  # stdout, which keeps a browser port (xterm.js) possible with no C extension.
  class Screen
    RESET = "\e[0m"
    BOLD = "\e[1m"
    DIM = "\e[2m"
    ITALIC = "\e[3m"

    RUBY = 160
    GREEN = 71
    YELLOW = 179
    GREY = 244
    NARRATOR = 109
    FAINT = 238
    WHITE = 253

    FALLBACK_SIZE = [24, 80].freeze

    def initialize(out: $stdout, input: $stdin)
      @out = out
      @input = input
      @colour = ENV['NO_COLOR'].to_s.empty? && out.tty?
    end

    # The alternate screen buffer, so quitting restores the previous terminal
    # contents. The same approach htop and lazygit take.
    def open
      invalidate
      write("\e[?1049h\e[?25l")
      @input.raw! if @input.tty?
    end

    def close
      @input.cooked! if @input.tty?
      write("\e[?25h\e[?1049l")
    end

    def size
      rows, columns = @input.tty? ? @input.winsize : FALLBACK_SIZE
      [rows.to_i, columns.to_i]
    rescue StandardError
      FALLBACK_SIZE
    end

    # One write per frame, to avoid flicker from partial repaints. A frame
    # identical to the previous one is skipped: the loop runs several times a
    # second and the screen rarely changes, so redrawing unconditionally wrote
    # around 23 KB/s while idle.
    def draw(lines)
      rows, = size
      visible = lines.first(rows)
      return if visible == @painted

      @painted = visible.dup
      write(frame(visible))
    end

    def invalidate
      @painted = nil
    end

    # Returns nil on timeout, which is what lets a single loop poll both the
    # keyboard and the filesystem.
    def read_key(timeout)
      if @input.wait_readable(timeout)
        key = @input.getc
        escape?(key) ? swallow_escape : key
      end
    end

    def paint(text, colour = nil, bold: false, dim: false, italic: false)
      styles = +''
      styles << BOLD if bold
      styles << DIM if dim
      styles << ITALIC if italic
      styles << "\e[38;5;#{colour}m" if colour

      if @colour && !styles.empty?
        "#{styles}#{text}#{RESET}"
      else
        text
      end
    end

    private
      def frame(lines)
        lines.each_with_index.inject(+"\e[H") do |frame, (line, index)|
          frame << "\e[#{index + 1};1H\e[K" << line
        end << "\e[J"
      end

      def escape?(key)
        key == "\e" && @input.wait_readable(0.01)
      end

      # Read the rest of the sequence so an arrow key doesn't arrive as "q".
      def swallow_escape
        @input.getc while @input.wait_readable(0.001)
        :escape
      end

      def write(string)
        @out.write(string)
        @out.flush
      rescue Errno::EPIPE
        nil
      end
  end
end
