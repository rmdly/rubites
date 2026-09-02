# frozen_string_literal: true

module Rubites
  # One execution of one level, run on a thread so the game loop keeps
  # rendering and reading keys while it happens. Run inline, a level that hangs
  # would freeze the game until it timed out.
  class Attempt
    attr_reader :trigger, :previous

    def initialize(runner, level, trigger:, previous: nil)
      @runner = runner
      @trigger = trigger
      @previous = previous
      @thread = Thread.new { runner.run(level) }
    end

    def running?
      @thread.alive?
    end

    def result
      @thread.value
    end

    def cancel
      @runner.cancel
      @thread.kill
    end
  end
end
