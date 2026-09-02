# frozen_string_literal: true

module Rubites
  # A span of seconds, rendered the way a stopwatch would show it.
  Duration = Data.define(:seconds) do
    def self.ago(time)
      seconds = (Time.now - time).round
      seconds < 60 ? "#{seconds}s ago" : "#{seconds / 60}m ago"
    end

    def initialize(seconds:)
      super(seconds: seconds.to_i)
    end

    def to_s
      if seconds < 60
        "#{seconds}s"
      elsif seconds < 3600
        format('%d:%02d', *seconds.divmod(60))
      else
        hours, rest = seconds.divmod(3600)
        format('%d:%02d:%02d', hours, *rest.divmod(60))
      end
    end
  end
end
