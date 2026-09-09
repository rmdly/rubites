# frozen_string_literal: true

module Rubites
  # One exercise, parsed from its own source file. The title, prose, expected
  # output, hint and narration all live in the header comments.
  #
  # Exercises are numbered `level.index`, so 1.0 is the first exercise of level
  # 1. The level is the topic; the index is the step within it.
  class Exercise
    TITLE = /^#\s*Exercise\s+(\d+)\.(\d+)\s*:\s*(.+)$/i
    EXPECTED = /^#\s*Expected output:\s*(.*)$/i
    HINT = /^#\s*Hint:\s*(.*)$/i
    NARRATOR = /^#\s*Narrator:\s*(.*)$/i
    TODO = /^#\s*TODO/i
    NUMBERED = /\A(\d+)\.(\d+)/
    UNNUMBERED = [0, 0].freeze

    attr_reader :path, :level, :index, :title

    # Searched recursively, since exercises are filed under levels/<level>/,
    # and sorted numerically rather than by path, so level 10 lands after
    # level 2 instead of between 1 and 3.
    def self.load_all(directory)
      Dir.glob(File.join(directory, '**', '*.rb')).map { |path| new(path) }.sort_by(&:position)
    end

    def initialize(path)
      @path = path
      parse
    end

    def basename
      File.basename(@path, '.rb')
    end

    def number
      "#{@level}.#{@index}"
    end

    def position
      [@level, @index]
    end

    # "1.2" picks one exercise. A bare "1" picks the level, which is how
    # `--author 1` opens at the start of it.
    def matches?(target)
      target.to_s.include?('.') ? number == target.to_s : @level == target.to_i
    end

    def expected
      @expected.join("\n")
    end

    def expected_lines
      Text.lines(expected)
    end

    def expected?
      !@expected.empty?
    end

    def hint
      sentence(@hint)
    end

    def narrator
      sentence(@narrator)
    end

    def prose
      @prose.join(' ').squeeze(' ').strip
    end

    private
      def sentence(parts)
        parts.join(' ') unless parts.empty?
      end

      def parse
        @level = nil
        @index = nil
        @title = basename.tr('_', ' ')
        @prose = []
        @expected = []
        @hint = []
        @narrator = []

        header.each { |line| absorb(line) }
        @level, @index = numbered_filename if @level.nil?
      end

      # Only the leading comment block is metadata. Reading stops at the first
      # line of code, so the learner's own comments are ignored.
      def header
        File.foreach(@path).take_while { |line| line.start_with?('#') || line.strip.empty? }
      end

      def absorb(line)
        case line
        when TITLE then absorb_title(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3))
        when EXPECTED then @expected << Regexp.last_match(1)
        when HINT then @hint << Regexp.last_match(1)
        when NARRATOR then @narrator << Regexp.last_match(1)
        when TODO then nil
        else absorb_prose(line)
        end
      end

      def absorb_title(level, index, title)
        @level = level.to_i
        @index = index.to_i
        @title = title.strip
      end

      def numbered_filename
        match = basename.match(NUMBERED)
        match ? [match[1].to_i, match[2].to_i] : UNNUMBERED
      end

      def absorb_prose(line)
        text = line.sub(/^#\s?/, '').rstrip
        @prose << text unless text.empty?
      end
  end
end
