# frozen_string_literal: true

module Rubites
  # What the level view says about the last run, and in what colour.
  Status = Data.define(:text, :colour)

  class Status
    UNAUTHORED = 'this level has no "# Expected output:" line yet'
    ERROR_ROOM = 58

    def self.running
      new(text: 'running…', colour: Screen::YELLOW)
    end

    def self.waiting
      new(text: '…', colour: Screen::GREY)
    end

    def self.of(result, difference: nil)
      case result.state
      when :no_expectation then new(text: UNAUTHORED, colour: Screen::YELLOW)
      when :passed then new(text: 'passing', colour: Screen::GREEN)
      when :timeout then new(text: timed_out, colour: Screen::YELLOW)
      when :errored then new(text: "error: #{first_error_line(result)}", colour: Screen::RUBY)
      else new(text: "not yet: #{difference&.summary}", colour: Screen::GREY)
      end
    end

    def self.timed_out
      "timed out after #{Runner::TIMEOUT}s. Infinite loop?"
    end
    private_class_method :timed_out

    def self.first_error_line(result)
      line = Text.lines(result.error).find { |candidate| !candidate.strip.empty? }
      Text.clip(line.to_s.strip.sub(%r{\A.*/}, ''), ERROR_ROOM)
    end
    private_class_method :first_error_line
  end
end
