# frozen_string_literal: true

require 'json'

module Rubites
  # Which levels are cleared, and what each one cost. Levels unlock in order, so
  # only the cleared set needs recording.
  class Progress
    FILENAME = '.rubites-progress.json'

    Stat = Data.define(:seconds, :runs) do
      def initialize(seconds:, runs:)
        super(seconds: seconds.to_i, runs: runs.to_i)
      end

      def duration = Duration.new(seconds: seconds)
    end

    def initialize(root)
      @path = File.join(root, FILENAME)
      @solved, @stats = load
    end

    # Keyed on the level number rather than the filename, so renaming a slug
    # (030_blocks to 030_yielding) keeps the cleared state. Renumbering does not.
    def solved?(exercise)
      @solved.include?(exercise.number)
    end

    def solve(exercise, seconds: nil, runs: nil)
      @stats[exercise.number] = Stat.new(seconds: seconds, runs: runs) if seconds
      @solved << exercise.number unless solved?(exercise)
      save
    end

    def stat(exercise)
      @stats[exercise.number]
    end

    def count
      @solved.size
    end

    def total_duration
      Duration.new(seconds: @stats.values.sum(&:seconds))
    end

    def total_runs
      @stats.values.sum(&:runs)
    end

    # The first uncleared level, which is what enforces the in-order
    # progression: there is no code path to a later one while it stands.
    def current(exercises)
      exercises.find { |exercise| !solved?(exercise) }
    end

    def reset
      @solved = []
      @stats = {}
      save
    end

    private
      def load
        if File.exist?(@path)
          restore(JSON.parse(File.read(@path)))
        else
          [[], {}]
        end
      rescue JSON::ParserError, SystemCallError
        [[], {}]
      end

      # Save files written before this keyed on the basename. Take the number.
      def restore(data)
        solved = Array(data['solved']).map { |name| number(name) }
        stats = Hash(data['stats']).filter_map do |name, values|
          [number(name), Stat.new(seconds: values['seconds'], runs: values['runs'])] if values.is_a?(Hash)
        end

        [solved, stats.to_h]
      end

      def number(name)
        name.to_s[/\A\d+/] || name.to_s
      end

      def save
        File.write(@path, "#{JSON.pretty_generate(payload)}\n")
      rescue SystemCallError
        # A read-only checkout can still be played, just not saved.
        nil
      end

      def payload
        {
          'solved' => @solved,
          'stats' => @stats.transform_values { |stat| { 'seconds' => stat.seconds, 'runs' => stat.runs } }
        }
      end
  end
end
