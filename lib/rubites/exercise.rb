# frozen_string_literal: true

module Rubites
  # One level, parsed from its own source file. The title, prose, expected
  # output, hint and narration all live in the header comments.
  class Exercise
    TITLE = /^#\s*(?:Level|Exercise)\s+(\d+)\s*:\s*(.+)$/i
    EXPECTED = /^#\s*Expected output:\s*(.*)$/i
    HINT = /^#\s*Hint:\s*(.*)$/i
    NARRATOR = /^#\s*Narrator:\s*(.*)$/i
    TODO = /^#\s*TODO/i
    UNNUMBERED = '000'

    attr_reader :path, :number, :title

    def self.load_all(directory)
      Dir.glob(File.join(directory, '*.rb')).sort.map { |path| new(path) }
    end

    def initialize(path)
      @path = path
      parse
    end

    def basename
      File.basename(@path, '.rb')
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
        @number = nil
        @title = basename.tr('_', ' ')
        @prose = []
        @expected = []
        @hint = []
        @narrator = []

        header.each { |line| absorb(line) }
        @number = numbered_filename if @number.nil?
      end

      # Only the leading comment block is metadata. Reading stops at the first
      # line of code, so the learner's own comments are ignored.
      def header
        File.foreach(@path).take_while { |line| line.start_with?('#') || line.strip.empty? }
      end

      def absorb(line)
        case line
        when TITLE then absorb_title(Regexp.last_match(1), Regexp.last_match(2))
        when EXPECTED then @expected << Regexp.last_match(1)
        when HINT then @hint << Regexp.last_match(1)
        when NARRATOR then @narrator << Regexp.last_match(1)
        when TODO then nil
        else absorb_prose(line)
        end
      end

      def absorb_title(number, title)
        @number = number
        @title = title.strip
      end

      def numbered_filename
        basename[/\A\d+/] || UNNUMBERED
      end

      def absorb_prose(line)
        text = line.sub(/^#\s?/, '').rstrip
        @prose << text unless text.empty?
      end
  end
end
