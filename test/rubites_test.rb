# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/rubites'

class ExerciseTest < Minitest::Test
  def test_it_reads_the_header
    exercise = build(<<~LEVEL)
      # Level 007: Quotes
      #
      # Double quotes interpolate. Single quotes do not.
      #
      # Expected output: one
      # Expected output: two
      # Hint: try double quotes

      # TODO: fix this
      puts 'one'
    LEVEL

    assert_equal '007', exercise.number
    assert_equal 'Quotes', exercise.title
    assert_equal "one\ntwo", exercise.expected
    assert_equal 'try double quotes', exercise.hint
    assert_includes exercise.prose, 'Double quotes interpolate'
    refute_includes exercise.prose, 'TODO'
    refute_includes exercise.prose, 'Expected output'
  end

  def test_it_accepts_the_older_exercise_header
    assert_equal 'Variables', build("# Exercise 001: Variables\n#\n# Expected output: hi\n\nputs 'hi'\n").title
  end

  # Parsing stops at the first line of code, so later comments are ignored.
  def test_it_stops_reading_at_the_first_line_of_code
    exercise = build("# Level 001: One\n#\n# Expected output: hi\n\nputs 'hi'\n# Hint: sneaky\n")

    assert_nil exercise.hint
  end

  def test_a_level_with_no_expected_output_is_not_runnable
    refute_predicate build("# Level 001: One\n\nputs 'hi'\n"), :expected?
  end

  private

    def build(source)
      @dir ||= Dir.mktmpdir
      path = File.join(@dir, '001_level.rb')
      File.write(path, source)
      Rubites::Exercise.new(path)
    end
end

class RunnerTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @runner = Rubites::Runner.new
  end

  def test_matching_output_passes
    assert_predicate run_level("# Level 1: x\n# Expected output: hi\nputs 'hi'\n"), :passed?
  end

  def test_trailing_whitespace_is_forgiven
    assert_predicate run_level("# Level 1: x\n# Expected output: hi\nputs 'hi   '\n"), :passed?
  end

  def test_wrong_output_fails
    result = run_level("# Level 1: x\n# Expected output: hi\nputs 'bye'\n")

    assert_predicate result, :failed?
    assert_equal "bye\n", result.output
  end

  def test_a_raising_level_reports_the_error
    result = run_level("# Level 1: x\n# Expected output: hi\nnope\n")

    assert_predicate result, :errored?
    assert_match(/nope/, result.error)
  end

  private

    def run_level(source)
      path = File.join(@dir, '001_level.rb')
      File.write(path, source)
      @runner.run(Rubites::Exercise.new(path))
    end
end

class ProgressTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @levels = %w[001 002 003].map do |number|
      path = File.join(@dir, "#{number}_level.rb")
      File.write(path, "# Level #{number}: L#{number}\n# Expected output: x\nputs 'x'\n")
      Rubites::Exercise.new(path)
    end
  end

  # This is what enforces the in-order progression.
  def test_the_current_level_is_always_the_first_unsolved_one
    progress = Rubites::Progress.new(@dir)

    assert_equal @levels[0].basename, progress.current(@levels).basename

    progress.solve(@levels[0])

    assert_equal @levels[1].basename, progress.current(@levels).basename
  end

  def test_solving_out_of_order_does_not_skip_the_gap
    progress = Rubites::Progress.new(@dir)
    progress.solve(@levels[2])

    assert_equal @levels[0].basename, progress.current(@levels).basename
  end

  def test_progress_survives_a_restart
    Rubites::Progress.new(@dir).solve(@levels[0])

    assert_equal 1, Rubites::Progress.new(@dir).count
  end

  def test_reset_forgets_everything
    progress = Rubites::Progress.new(@dir)
    progress.solve(@levels[0])
    progress.reset

    assert_equal 0, progress.count
  end

  def test_all_levels_solved_means_there_is_no_current_level
    progress = Rubites::Progress.new(@dir)
    @levels.each { |level| progress.solve(level) }

    assert_nil progress.current(@levels)
  end
end

# The levels that ship in this repo, checked against the authoring contract.
class LevelsTest < Minitest::Test
  LEVELS = Rubites::Exercise.load_all(File.expand_path('../exercises', __dir__))

  def test_there_are_levels
    refute_empty LEVELS
  end

  def test_level_numbers_are_unique
    duplicates = LEVELS.map(&:number).tally.select { |_, count| count > 1 }.keys

    assert_empty duplicates, "more than one level numbered: #{duplicates.join(', ')}"
  end

  LEVELS.each do |level|
    define_method(:"test_#{level.basename}_is_introduced_properly") do
      refute_empty level.title
      assert_predicate level, :expected?
      refute_empty level.prose
    end

    # A level that already prints its expected output has nothing left to fix.
    define_method(:"test_#{level.basename}_ships_unsolved") do
      refute_predicate Rubites::Runner.new.run(level), :passed?
    end
  end
end

class DiffTest < Minitest::Test
  def test_it_finds_a_typo_mid_string
    point = diff('Hello, Rubites!', 'Hello, World!')

    assert_equal 1, point.line
    assert_equal 8, point.column
    assert_equal 'line 1 differs at column 8', point.summary
  end

  def test_it_finds_a_missing_full_stop_at_the_end
    assert_equal 21, diff('Ruby is 33 years old.', 'Ruby is 33 years old').column
  end

  # Spacing differences are the hardest to see in the side-by-side panels.
  def test_it_names_a_spacing_difference_as_such
    point = diff('Ruby is  33', 'Ruby is 33')

    assert_predicate point, :whitespace?
    assert_includes point.summary, 'spacing'
  end

  def test_leading_whitespace_counts_as_spacing
    assert_predicate diff('  indented', 'indented'), :whitespace?
  end

  def test_a_short_output_reports_the_missing_line
    point = diff("a\nb\nc", "a\nb")

    assert_predicate point, :missing_line?
    assert_equal 'line 3 is missing', point.summary
  end

  def test_a_long_output_reports_the_extra_line
    assert_predicate diff("a\nb", "a\nb\nc"), :extra_line?
  end

  # The runner forgives trailing whitespace, so the diff must agree with it.
  def test_trailing_whitespace_is_not_a_difference
    assert_nil diff('same', 'same   ')
  end

  def test_identical_output_has_no_difference
    assert_nil diff("a\nb", "a\nb")
  end

  private

    def diff(expected, actual)
      Rubites::Diff.between(expected, actual)
    end
end

class UnauthoredLevelTest < Minitest::Test
  # An unfinished level reports its own state rather than a failure.
  def test_a_level_with_no_expected_output_reports_itself
    dir = Dir.mktmpdir
    path = File.join(dir, '001_level.rb')
    File.write(path, "# Level 001: Unfinished\n#\n# Prose.\n\nputs 'hi'\n")

    result = Rubites::Runner.new.run(Rubites::Exercise.new(path))

    assert_predicate result, :unauthored?
    refute_predicate result, :passed?
  end
end

class NarratorTest < Minitest::Test
  def test_the_narrator_is_read_and_kept_out_of_the_prose
    dir = Dir.mktmpdir
    path = File.join(dir, '001_level.rb')
    File.write(path, <<~LEVEL)
      # Level 001: Voice
      #
      # Teaching prose.
      #
      # Narrator: Some narration for this level.
      # Expected output: hi

      puts 'hi'
    LEVEL

    exercise = Rubites::Exercise.new(path)

    assert_equal 'Some narration for this level.', exercise.narrator
    assert_equal 'Teaching prose.', exercise.prose
  end

  def test_a_level_without_a_narrator_has_none
    dir = Dir.mktmpdir
    path = File.join(dir, '001_level.rb')
    File.write(path, "# Level 001: Quiet\n#\n# Prose.\n#\n# Expected output: hi\n\nputs 'hi'\n")

    assert_nil Rubites::Exercise.new(path).narrator
  end
end

class ProgressStatsTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    path = File.join(@dir, '001_level.rb')
    File.write(path, "# Level 001: One\n# Expected output: x\nputs 'x'\n")
    @level = Rubites::Exercise.new(path)
  end

  def test_it_records_time_and_runs_for_a_cleared_level
    progress = Rubites::Progress.new(@dir)
    progress.solve(@level, seconds: 222, runs: 7)

    stat = progress.stat(@level)

    assert_equal 222, stat.seconds
    assert_equal 7, stat.runs
    assert_equal '3:42', stat.duration.to_s
  end

  def test_a_sub_minute_clear_reads_in_seconds
    progress = Rubites::Progress.new(@dir)
    progress.solve(@level, seconds: 41, runs: 2)

    assert_equal '41s', progress.stat(@level).duration.to_s
  end

  def test_stats_survive_a_restart_and_feed_the_totals
    Rubites::Progress.new(@dir).solve(@level, seconds: 100, runs: 3)
    reloaded = Rubites::Progress.new(@dir)

    assert_equal 100, reloaded.total_duration.seconds
    assert_equal 3, reloaded.total_runs
  end

  # Save files written before stats existed must still load.
  def test_it_reads_a_save_file_with_no_stats
    File.write(File.join(@dir, Rubites::Progress::FILENAME), '{"solved":["001_level"]}')
    progress = Rubites::Progress.new(@dir)

    assert_equal 1, progress.count
    assert_nil progress.stat(@level)
    assert_equal 0, progress.total_duration.seconds
  end

  def test_reset_clears_stats_too
    progress = Rubites::Progress.new(@dir)
    progress.solve(@level, seconds: 100, runs: 3)
    progress.reset

    assert_equal 0, progress.total_duration.seconds
    assert_nil progress.stat(@level)
  end
end

class TextTest < Minitest::Test
  def test_width_counts_terminal_cells_not_characters
    assert_equal 5, Rubites::Text.width('plain')
    assert_equal 13, Rubites::Text.width('ruby 💎 rocks')
    assert_equal 6, Rubites::Text.width('日本語')
  end

  def test_width_ignores_colour_codes
    assert_equal 4, Rubites::Text.width("\e[1m\e[38;5;160mfour\e[0m")
  end

  def test_clip_measures_the_result_in_columns
    clipped = Rubites::Text.clip('ruby 💎 rocks', 8)

    assert_equal 8, Rubites::Text.width(clipped)
  end

  def test_clip_leaves_a_string_that_already_fits
    assert_equal 'short', Rubites::Text.clip('short', 20)
  end

  def test_ljust_pads_to_a_column_count
    assert_equal 6, Rubites::Text.width(Rubites::Text.ljust('日本語', 6))
    assert_equal 8, Rubites::Text.width(Rubites::Text.ljust('日本語', 8))
  end

  def test_wrap_breaks_on_words
    assert_equal ['one two', 'three'], Rubites::Text.wrap('one two three', 8)
  end

  def test_wrap_of_nothing_is_one_empty_line
    assert_equal [''], Rubites::Text.wrap('', 10)
  end

  def test_lines_strips_trailing_whitespace
    assert_equal %w[a b], Rubites::Text.lines("a  \nb\t\n")
  end

  def test_pad_fills_up_to_a_target
    assert_equal ['a', '', ''], Rubites::Text.pad(['a'], 3)
  end

  def test_pad_never_truncates
    assert_equal %w[a b c], Rubites::Text.pad(%w[a b c], 2)
  end
end

class DurationTest < Minitest::Test
  def test_seconds_under_a_minute
    assert_equal '41s', duration(41).to_s
  end

  def test_minutes_and_seconds
    assert_equal '3:42', duration(222).to_s
  end

  def test_hours_minutes_and_seconds
    assert_equal '1:02:03', duration(3723).to_s
  end

  def test_it_takes_a_float_from_the_clock
    assert_equal '2s', duration(2.7).to_s
  end

  def test_ago_reads_coarsely
    assert_equal '3s ago', Rubites::Duration.ago(Time.now - 3)
    assert_equal '2m ago', Rubites::Duration.ago(Time.now - 125)
  end

  private

    def duration(seconds)
      Rubites::Duration.new(seconds: seconds)
    end
end

class FlashTest < Minitest::Test
  def test_a_new_flash_is_showing
    assert_predicate Rubites::Flash.saying('ran'), :showing?
  end

  def test_it_stops_showing_once_it_expires
    stale = Rubites::Flash.new(message: 'ran', expires_at: Time.now - 1)

    refute_predicate stale, :showing?
  end
end

class TallyTest < Minitest::Test
  def setup
    @tally = Rubites::Tally.new
  end

  def test_it_starts_with_nothing_run
    refute_predicate @tally, :ran?
    assert_equal 0, @tally.runs
  end

  def test_recording_counts_the_session_and_the_level
    2.times { @tally.record(:rerun) }

    assert_equal 2, @tally.runs
    assert_equal 2, @tally.level_runs
    assert_equal :rerun, @tally.trigger
    assert_predicate @tally, :ran?
  end

  # The session count carries across levels; the level count does not.
  def test_starting_a_level_resets_only_the_level_count
    @tally.record(:save)
    @tally.start_level
    @tally.record(:save)

    assert_equal 2, @tally.runs
    assert_equal 1, @tally.level_runs
  end

  def test_elapsed_is_nil_until_a_level_starts
    assert_nil @tally.elapsed

    @tally.start_level

    assert_operator @tally.elapsed, :>=, 0
  end
end
