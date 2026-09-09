# frozen_string_literal: true

module Rubites
  module Views
    class Complete < View
      needs :exercise, :stat, :cleared, :total, :upcoming

      def lines
        middle(body)
      end

      private
        def body
          [
            paint('EXERCISE COMPLETE', Screen::GREEN, bold: true),
            '',
            paint("#{exercise.number} · #{exercise.title}", Screen::WHITE),
            *cost,
            '',
            paint("#{cleared} of #{total} cleared", Screen::GREY),
            *next_up,
            '',
            '',
            paint('press any key to continue', Screen::YELLOW, dim: true)
          ]
        end

        def cost
          ['', paint("#{stat.duration} · #{pluralise(stat.runs, 'run')}", Screen::GREY)] if stat
        end

        def next_up
          ['', paint("next up: #{upcoming.number} #{upcoming.title}", Screen::RUBY)] if upcoming
        end
    end
  end
end
