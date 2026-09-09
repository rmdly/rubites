# frozen_string_literal: true

module Rubites
  # The command line: flags, validation, and handing off to the game. Every
  # branch returns the exit status so the binary is one line.
  class CLI
    TARGET = /\A\d+(?:\.\d+)?\z/

    USAGE = <<~TEXT
      rubites: learn to code in Ruby

      Usage:
        start                play
        start --author [N]   unlock everything and start at N, for writing
                             exercises. N is 3.2 for one exercise, or 3 for
                             the start of level 3.
        start --check        run every exercise once and report (no TUI, for CI)
        start --reset        forget all progress
        start --help         this

      In game:
        h  hint            r  rerun          m  level map       q  quit
        n  next exercise   p  previous       (n and p need --author)

      `start` works inside this directory once direnv has been allowed.
      Without direnv, run bin/rubites instead.
    TEXT

    def initialize(argv, root:)
      @argv = argv
      # Overridable so the tests can run the real binary against their own levels.
      @levels_dir = ENV.fetch('RUBITES_LEVELS') { File.join(root, 'levels') }
      @state_dir = ENV.fetch('RUBITES_STATE') { root }
    end

    def run
      case @argv.first
      when '--help', '-h' then help
      when '--reset' then reset
      when '--check' then check
      when '--author' then author
      when nil then play
      else unknown
      end
    end

    private
      def help
        puts USAGE
        0
      end

      def reset
        Progress.new(@state_dir).reset
        puts 'Progress reset.'
        0
      end

      # Plain-text mode for CI, which has no TTY for the game to take over.
      def check
        runner = Runner.new
        passing = exercises.count do |exercise|
          result = runner.run(exercise)
          puts format('%-40s %s', exercise.basename, result.passed? ? 'pass' : result.state)
          result.passed?
        end

        puts
        puts "#{passing}/#{exercises.size} exercises passing"
        passing == exercises.size ? 0 : 1
      end

      def author
        target = @argv[1]

        if target && !TARGET.match?(target)
          complain("--author takes an exercise or a level, e.g. --author 3.2 or --author 3 (got #{target.inspect})")
        elsif target && exercises.any? && exercises.none? { |exercise| exercise.matches?(target) }
          complain("There's no #{target}. Exercises run #{exercises.first.number} to #{exercises.last.number}.")
        else
          play(author: true, start_at: target)
        end
      end

      def play(author: false, start_at: nil)
        if exercises.empty?
          complain("No exercises found in #{@levels_dir}. Add one and run again.")
        elsif !$stdout.tty?
          complain('rubites needs a terminal. Use --check for plain output.')
        else
          start(author: author, start_at: start_at)
        end
      end

      def start(author:, start_at:)
        game(author: author, start_at: start_at).run
        0
      rescue Interrupt
        0
      rescue StandardError => e
        # Game#run's ensure has already restored the screen, so this is readable.
        warn "rubites crashed: #{e.class}: #{e.message}"
        warn e.backtrace.first(5).join("\n")
        1
      end

      def game(author:, start_at:)
        Game.new(
          levels_dir: @levels_dir,
          progress: Progress.new(@state_dir),
          screen: Screen.new,
          author: author,
          start_at: start_at
        )
      end

      def unknown
        warn "Unknown option: #{@argv.first}"
        puts USAGE
        1
      end

      def complain(message)
        warn message
        1
      end

      def exercises
        @exercises ||= Exercise.load_all(@levels_dir)
      end
  end
end
