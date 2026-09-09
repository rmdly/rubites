# frozen_string_literal: true

module Rubites
  # A message shown for a moment after a run, so a rerun that produces the same
  # output still gives some visible feedback.
  Flash = Data.define(:message, :expires_at)

  class Flash
    LIFETIME = 2.0

    def self.saying(message)
      new(message: message, expires_at: Time.now + LIFETIME)
    end

    def showing?
      Time.now <= expires_at
    end
  end
end
