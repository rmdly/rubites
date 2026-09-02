# frozen_string_literal: true

module Rubites
  module Views
    class Splash < View
      needs :cleared, :total, :author

      def lines
        middle(body)
      end

      private
        def body
          [
            paint('R U B I T E S', Screen::RUBY, bold: true),
            '',
            paint('Learn to code in Ruby.', Screen::GREY),
            '',
            paint("#{username} · #{Time.now.strftime('%A %-d %B, %H:%M')}", Screen::WHITE),
            '',
            paint("#{cleared} of #{total} levels cleared", Screen::GREY),
            *author_note,
            '',
            '',
            paint('press any key to begin', Screen::YELLOW, dim: true)
          ]
        end

        def author_note
          ['', paint('author mode: every level unlocked', Screen::YELLOW)] if author
        end
    end
  end
end
