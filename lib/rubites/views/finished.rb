# frozen_string_literal: true

module Rubites
  module Views
    class Finished < View
      needs :total, :duration, :runs

      def lines
        middle(body)
      end

      private
        def body
          [
            paint('ALL LEVELS CLEARED', Screen::YELLOW, bold: true),
            '',
            paint("#{total} of #{total}", Screen::WHITE),
            '',
            paint("#{duration} · #{runs} runs", Screen::GREY),
            '',
            paint('press any key to leave', Screen::GREY, dim: true)
          ]
        end
    end
  end
end
