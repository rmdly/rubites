# frozen_string_literal: true

module Rubites
  # The state machine: which screen is showing, what each key does, and the loop
  # that ties keyboard polling to file watching.
  class Game
    TICK = 0.06
    MIN_COLUMNS = 58
    MIN_ROWS = 16
    RESCAN = 1.0

    # Raw mode delivers Ctrl-C as a byte rather than a signal.
    QUIT_KEYS = ['q', "\C-c"].freeze

    def initialize(exercises_dir:, progress:, screen:,
                   runner: Runner.new, watcher: Watcher.new, author: false, level: nil)
      @exercises_dir = exercises_dir
      @exercises = Exercise.load_all(exercises_dir)
      @progress = progress
      @screen = screen
      @runner = runner
      @watcher = watcher
      @author = author
      @index = level ? index_of(level) : 0
      @tally = Tally.new
      @state = :splash
      @scanned_at = Time.now
    end

    def run
      @screen.open
      @level = current_level
      @state = :finished if @level.nil?

      until @state == :quit
        draw
        key = @screen.read_key(TICK)
        press(key) if key
        settle
        watch
        rescan
      end
    ensure
      @attempt&.cancel
      @screen.close
    end

    private
      def total
        @exercises.size
      end

      # Quit is handled ahead of the per-screen keys so it works on every screen.
      def press(key)
        if QUIT_KEYS.include?(key)
          @state = :quit
        else
          case @state
          when :splash, :complete then enter_level
          when :finished then @state = :quit
          when :map then @state = :level
          when :level then level_key(key)
          end
        end
      end

      def level_key(key)
        case key
        when 'h' then @hint = !@hint
        when 'r' then start(:rerun)
        when 'm' then @state = :map
        when 'n' then step(1)
        when 'p' then step(-1)
        end
      end

      def step(delta)
        return unless @author && total.positive?

        @index = (@index + delta).clamp(0, total - 1)
        enter_level
      end

      def watch
        reread if @state == :level && !running? && @watcher.changed?(@level.path)
      end

      # The file can vanish between the mtime check and the read.
      def reread
        @level = Exercise.new(@level.path)
        start(:save)
      rescue Errno::ENOENT
        nil
      end

      # Levels are written while the game is running, so the list is re-read
      # periodically rather than once at boot.
      def rescan
        return if Time.now - @scanned_at < RESCAN

        @scanned_at = Time.now
        found = Exercise.load_all(@exercises_dir)
        reload(found) unless found.map(&:basename) == @exercises.map(&:basename)
      end

      def reload(found)
        @exercises = found
        return if @state == :splash

        level = current_level
        enter_level if level && level.path != @level&.path
      end

      def start(trigger)
        return if running?

        @attempt = Attempt.new(@runner, @level, trigger: trigger, previous: @result&.state)
      end

      def running?
        @attempt&.running?
      end

      def settle
        return if @attempt.nil? || @attempt.running?

        finished = @attempt
        @attempt = nil
        @result = finished.result
        @difference = @result.failed? ? Diff.between(@level.expected, @result.output) : nil

        @tally.record(finished.trigger)
        @flash = flash_for(finished)
        clear_level if @result.passed?
      end

      def flash_for(attempt)
        return nil if attempt.trigger == :enter

        verb = attempt.trigger == :rerun ? 'reran' : 'ran on save'
        repeat = ', same result' if attempt.previous == @result.state
        Flash.saying("#{verb}, run #{@tally.runs}#{repeat}")
      end

      def clear_level
        # Author mode does not write progress, so previewing a level does not
        # mark it cleared.
        @progress.solve(@level, seconds: @tally.elapsed, runs: @tally.level_runs) unless @author
        @index += 1 if @author && @index < total - 1
        @state = :complete
      end

      def enter_level
        @level = current_level

        if @level.nil?
          @state = :finished
        else
          @state = :level
          @hint = false
          @tally.start_level
          @watcher.watch(@level.path)
          start(:enter)
        end
      end

      def current_level
        if @exercises.empty?
          nil
        elsif @author
          @exercises[@index.clamp(0, total - 1)]
        else
          @progress.current(@exercises)
        end
      end

      def next_level
        index = @exercises.index { |exercise| exercise.path == @level.path }
        @exercises[index + 1] if index
      end

      def index_of(number)
        wanted = format('%03d', number.to_i)
        @exercises.index { |exercise| exercise.number == wanted } || 0
      end

      def draw
        rows, columns = @screen.size

        if columns < MIN_COLUMNS || rows < MIN_ROWS
          @screen.draw(['terminal too small'])
        else
          @screen.draw(view(rows, columns).lines)
        end
      end

      def view(rows, columns)
        case @state
        when :level then level_view(rows, columns)
        when :map then map_view(rows, columns)
        when :complete then complete_view(rows, columns)
        when :finished then finished_view(rows, columns)
        else splash_view(rows, columns)
        end
      end

      def splash_view(rows, columns)
        Views::Splash.new(@screen, rows, columns,
                          cleared: @progress.count, total: total, author: @author)
      end

      def level_view(rows, columns)
        Views::Level.new(@screen, rows, columns,
                         level: @level, cleared: @progress.count, total: total,
                         status: status, result: @result, difference: @difference,
                         flash: @flash, hint: @hint, author: @author, tally: @tally)
      end

      def map_view(rows, columns)
        Views::Map.new(@screen, rows, columns,
                       exercises: @exercises, progress: @progress, current: @level)
      end

      def complete_view(rows, columns)
        Views::Complete.new(@screen, rows, columns,
                            level: @level, stat: @progress.stat(@level),
                            cleared: @progress.count, total: total, upcoming: next_level)
      end

      def finished_view(rows, columns)
        Views::Finished.new(@screen, rows, columns, total: total,
                                                    duration: @progress.total_duration,
                                                    runs: @progress.total_runs)
      end

      def status
        if running?
          Status.running
        elsif @result.nil?
          Status.waiting
        else
          Status.of(@result, difference: @difference)
        end
      end
  end
end
