# frozen_string_literal: true

module Rubites
  # Finds the first position where two outputs differ, so the game can point at
  # it. Side-by-side panels don't make a wrong capital letter or a double space
  # visible on their own.
  class Diff
    Point = Data.define(:line, :column, :expected, :actual, :kind) do
      def whitespace? = kind == :whitespace

      def missing_line? = kind == :missing_line

      def extra_line? = kind == :extra_line

      def positioned? = !missing_line? && !extra_line?

      def summary
        case kind
        when :missing_line then "line #{line} is missing"
        when :extra_line then "line #{line} is extra"
        when :whitespace then "line #{line} differs at column #{column} (spacing)"
        else "line #{line} differs at column #{column}"
        end
      end
    end

    def self.between(expected, actual)
      new(expected, actual).first
    end

    def initialize(expected, actual)
      @expected = Text.lines(expected)
      @actual = Text.lines(actual)
    end

    def first
      (0...[@expected.size, @actual.size].max).lazy.filter_map { |index| at(index) }.first
    end

    private
      def at(index)
        wanted = @expected[index]
        got = @actual[index]
        line = index + 1

        if wanted == got
          nil
        elsif got.nil?
          Point.new(line: line, column: nil, expected: wanted, actual: nil, kind: :missing_line)
        elsif wanted.nil?
          Point.new(line: line, column: nil, expected: nil, actual: got, kind: :extra_line)
        else
          divergence(line, wanted, got)
        end
      end

      def divergence(line, wanted, got)
        Point.new(
          line: line,
          column: column(wanted, got),
          expected: wanted,
          actual: got,
          kind: wanted.split == got.split ? :whitespace : :text
        )
      end

      # The runner forgives trailing whitespace, so a whitespace difference here
      # is leading or internal spacing.
      def column(wanted, got)
        (0...[wanted.length, got.length].max).find { |index| wanted[index] != got[index] } + 1
      end
  end
end
