# frozen_string_literal: true

module Rubites
  module Views
    class Complete < View
      needs :level, :stat, :cleared, :total, :upcoming

      def lines
        middle(body)
      end

      private
        def body
          [
            paint('LEVEL COMPLETE', Screen::GREEN, bold: true),
            '',
            paint("#{level.number} · #{level.title}", Screen::WHITE),
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
          ['', paint("next up: level #{upcoming.number} #{upcoming.title}", Screen::RUBY)] if upcoming
        end
    end
  end
end
