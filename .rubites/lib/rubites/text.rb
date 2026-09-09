# frozen_string_literal: true

module Rubites
  # Measuring and laying out text for a terminal, kept apart from Screen, which
  # owns the terminal itself.
  module Text
    ANSI = /\e\[[0-9;]*[A-Za-z]/
    ELLIPSIS = '…'

    # Characters that occupy two terminal cells. Padding computed from
    # String#length is one short for each of these, which misaligns the panels.
    # This approximates the Unicode width tables: it covers CJK, Hangul,
    # fullwidth forms and pictographs, and counts combining marks as one cell
    # rather than zero.
    WIDE_RANGES = [
      "\u{1100}-\u{115F}",   # Hangul Jamo
      "\u{2E80}-\u{303E}",   # CJK radicals and symbols
      "\u{3041}-\u{33FF}",   # Hiragana, Katakana, CJK compatibility
      "\u{3400}-\u{4DBF}",   # CJK extension A
      "\u{4E00}-\u{9FFF}",   # CJK unified ideographs
      "\u{A000}-\u{A4CF}",   # Yi
      "\u{AC00}-\u{D7A3}",   # Hangul syllables
      "\u{F900}-\u{FAFF}",   # CJK compatibility ideographs
      "\u{FE30}-\u{FE6F}",   # CJK compatibility forms
      "\u{FF00}-\u{FF60}",   # Fullwidth forms
      "\u{FFE0}-\u{FFE6}",   # Fullwidth signs
      "\u{1F300}-\u{1F9FF}", # Pictographs
      "\u{20000}-\u{2FFFD}", # CJK extension B and beyond
      "\u{30000}-\u{3FFFD}"
    ].freeze

    WIDE = /[#{WIDE_RANGES.join}]/

    extend self

    def width(string)
      bare(string).each_char.sum { |char| cells(char) }
    end

    def clip(string, columns)
      if width(string) <= columns
        string
      elsif columns < 1
        ''
      else
        "#{fitting(string, columns - 1)}#{ELLIPSIS}"
      end
    end

    def ljust(string, columns)
      padding = columns - width(string)

      if padding.positive?
        string + (' ' * padding)
      else
        string
      end
    end

    def lines(text)
      text.to_s.lines.map(&:rstrip)
    end

    def wrap(text, columns)
      words = text.to_s.split
      return [''] if words.empty?

      words.drop(1).each_with_object([words.first.dup]) do |word, wrapped|
        if wrapped.last.length + word.length + 1 <= columns
          wrapped.last << ' ' << word
        else
          wrapped << word.dup
        end
      end
    end

    def centre(lines, columns)
      lines.map { |line| (' ' * indent(line, columns)) + line }
    end

    def pad(lines, target)
      lines + Array.new([target - lines.size, 0].max, '')
    end

    private
      def bare(string)
        string.gsub(ANSI, '')
      end

      def cells(character)
        character.match?(WIDE) ? 2 : 1
      end

      def fitting(string, columns)
        string.each_char.each_with_object(+'') do |character, kept|
          break kept if width(kept) + cells(character) > columns

          kept << character
        end
      end

      def indent(line, columns)
        [(columns - width(line)) / 2, 0].max
      end
  end
end
