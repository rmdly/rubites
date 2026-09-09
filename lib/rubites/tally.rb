# frozen_string_literal: true

module Rubites
  # Run counts and timings, for the session and for the exercise in progress.
  class Tally
    attr_reader :runs, :exercise_runs, :ran_at, :trigger

    def initialize
      @runs = 0
      @exercise_runs = 0
      @trigger = nil
      @ran_at = nil
      @started_at = nil
    end

    def start_exercise
      @exercise_runs = 0
      @started_at = Time.now
    end

    def record(trigger)
      @runs += 1
      @exercise_runs += 1
      @trigger = trigger
      @ran_at = Time.now
    end

    def ran?
      !@ran_at.nil?
    end

    def elapsed
      Time.now - @started_at if @started_at
    end
  end
end
