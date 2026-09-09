# frozen_string_literal: true

require 'etc'

module Rubites
  # Common furniture for the full-screen views: geometry, painting, and the
  # rules and margins they are all built from.
  class View
    MARGIN = 2

    # Declares what the view is given. Views only ever read their inputs, so
    # the readers and the initializer are generated rather than written out.
    def self.needs(*names)
      attr_reader(*names)
      private(*names)

      define_method(:initialize) do |screen, rows, columns, **given|
        super(screen, rows, columns)
        names.each { |name| instance_variable_set(:"@#{name}", given.fetch(name)) }
      end
    end

    def initialize(screen, rows, columns)
      @screen = screen
      @rows = rows
      @columns = columns
    end

    private
      attr_reader :screen, :rows, :columns

      def inner
        columns - (MARGIN * 2)
      end

      def indent(line)
        "#{' ' * MARGIN}#{line}"
      end

      def paint(text, colour = nil, **styles)
        screen.paint(text, colour, **styles)
      end

      def rule(left, right)
        dashes = [inner - left.length - right.length - 6, 0].max

        paint("─ #{left} ", Screen::RUBY) +
          paint('─' * dashes, Screen::FAINT) +
          paint(" #{right} ─", Screen::FAINT)
      end

      def wrapped(text, colour, **styles)
        Text.wrap(text, inner - 2).map { |line| indent(paint(line, colour, **styles)) }
      end

      def middle(body)
        Text.pad([], [(rows - body.size) / 2, 1].max) + Text.centre(body, columns)
      end

      def pluralise(count, word)
        "#{count} #{word}#{'s' unless count == 1}"
      end

      def username
        ENV['USER'] || Etc.getlogin || 'rubyist'
      rescue StandardError
        'rubyist'
      end
  end
end
