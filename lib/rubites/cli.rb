# frozen_string_literal: true

module Rubites
  # The command line: flags, validation, and handing off to the game. Every
  # branch returns the exit status so the binary is one line.
  class CLI
    USAGE = <<~TEXT
      rubites: learn to code in Ruby

      Usage:
        start                play
        start --author [N]   unlock every level and start at N, for writing them
        start --check        run every level once and report (no TUI, for CI)
        start --reset        forget all progress
        start --help         this

      In game:
        h  hint            r  rerun          m  level map       q  quit
        n  next level      p  previous       (n and p need --author)

      `start` works inside this directory once direnv has been allowed.
      Without direnv, run bin/rubites instead.
    TEXT

    def initialize(argv, root:)
      @argv = argv
      # Overridable so the tests can run the real binary against their own levels.
      @exercises_dir = ENV.fetch('RUBITES_EXERCISES') { File.join(root, 'exercises') }
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
        passing = levels.count do |level|
          result = runner.run(level)
          puts format('%-40s %s', level.basename, result.passed? ? 'pass' : result.state)
          result.passed?
        end

        puts
        puts "#{passing}/#{levels.size} levels passing"
        passing == levels.size ? 0 : 1
      end

      def author
        number = @argv[1] ? Integer(@argv[1], exception: false) : 1

        if number.nil? || number < 1
          complain("--author takes a level number, e.g. --author 12 (got #{@argv[1].inspect})")
        elsif levels.any? && levels.none? { |level| level.number == numbered(number) }
          complain("There's no level #{numbered(number)}. Levels run #{levels.first.number} to #{levels.last.number}.")
        else
          play(author: true, level: number)
        end
      end

      def play(author: false, level: nil)
        if levels.empty?
          complain("No levels found in #{@exercises_dir}. Add one and run again.")
        elsif !$stdout.tty?
          complain('rubites needs a terminal. Use --check for plain output.')
        else
          start(author: author, level: level)
        end
      end

      def start(author:, level:)
        game(author: author, level: level).run
        0
      rescue Interrupt
        0
      rescue StandardError => e
        # Game#run's ensure has already restored the screen, so this is readable.
        warn "rubites crashed: #{e.class}: #{e.message}"
        warn e.backtrace.first(5).join("\n")
        1
      end

      def game(author:, level:)
        Game.new(
          exercises_dir: @exercises_dir,
          progress: Progress.new(@state_dir),
          screen: Screen.new,
          author: author,
          level: level
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

      def numbered(number)
        format('%03d', number)
      end

      def levels
        @levels ||= Exercise.load_all(@exercises_dir)
      end
  end
end
