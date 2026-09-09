# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/rubites'
require_relative 'support/terminal'

# Drives the real binary in a pty against its own exercises, so the game itself
# is covered rather than only the classes underneath it.
class TuiTest < Minitest::Test
  def setup
    @levels = Dir.mktmpdir('rubites-levels')
    @state = Dir.mktmpdir('rubites-state')
    @terminals = []

    write_exercise('1.0_first', 'First', expected: 'one', code: 'puts "wrong"', hint: 'print one')
    write_exercise('1.1_second', 'Second', expected: 'two', code: 'puts "wrong"')
    write_exercise('2.0_third', 'Third', expected: 'three', code: 'puts "wrong"')
  end

  def teardown
    @terminals.each(&:close)
    FileUtils.remove_entry(@levels)
    FileUtils.remove_entry(@state)
  end

  # ---- booting -------------------------------------------------------------

  def test_it_opens_on_the_splash_with_the_player_and_the_tally
    game = play

    screen = game.wait_for(/R U B I T E S/)

    assert_match(/Learn to code in Ruby\./, screen)
    assert_match(/tester/, screen)
    assert_match(/0 of 3 exercises cleared/, screen)
  end

  def test_any_key_starts_the_first_exercise
    game = play
    game.wait_for(/press any key to begin/)
    game.press(' ')

    assert_match(/EXERCISE 1\.0 · First/, game.wait_for(/EXERCISE 1\.0/))
  end

  def test_q_quits_from_the_splash
    game = play
    game.wait_for(/press any key to begin/)
    game.press('q')

    assert game.wait_for_exit, 'q on the splash should quit, not start a level'
  end

  # ---- the exercise view ------------------------------------------------------

  def test_it_shows_expected_and_actual_side_by_side
    game = at_first_exercise
    screen = game.wait_for(/not yet/)

    assert_match(/expected/, screen)
    assert_match(/yours/, screen)
    assert_match(/one/, screen)
    assert_match(/wrong/, screen)
  end

  def test_h_toggles_the_hint
    game = at_first_exercise
    game.wait_for(/not yet/)

    refute_match(/hint: print one/, game.text)

    game.press('h')

    assert_match(/hint: print one/, game.wait_for(/hint: print one/))
  end

  # ---- the thing the panels can't show -------------------------------------

  def test_it_points_at_the_column_where_the_output_diverges
    write_exercise('1.0_first', 'First', expected: 'Hello, Rubites!', code: 'puts "Hello, World!"')
    game = at_first_exercise

    screen = game.wait_for(/differs at column/)

    assert_match(/line 1 differs at column 8/, screen)

    caret = screen.lines.find { |line| line.strip == '^' }

    refute_nil caret, "expected a caret line, screen was:\n#{screen}"
    # Check the caret's column, not just that one was printed.
    yours = screen.lines.find { |line| line.match?(/yours\s+Hello, World!/) }

    assert_equal yours.index('World!'), caret.index('^')
  end

  def test_it_names_a_spacing_difference_rather_than_leaving_it_invisible
    write_exercise('1.0_first', 'First', expected: 'a  b', code: 'puts "a b"')
    game = at_first_exercise

    assert_match(/spacing/, game.wait_for(/spacing/))
  end

  # ---- rerun feedback ------------------------------------------------------

  def test_rerunning_says_so_even_when_nothing_changes
    game = at_first_exercise
    game.wait_for(/not yet/)
    game.press('r')

    screen = game.wait_for(/same result/)

    assert_match(/reran, run 2, same result/, screen)
  end

  def test_the_run_counter_climbs
    game = at_first_exercise
    game.wait_for(/not yet/)
    game.press('r')
    game.wait_for(/run 2/)
    game.press('r')

    assert_match(/run 3/, game.wait_for(/run 3/))
  end

  # ---- progression ---------------------------------------------------------

  def test_saving_a_correct_answer_clears_the_exercise_and_offers_the_next
    game = at_first_exercise
    game.wait_for(/not yet/)

    solve('1.0_first', 'one')

    screen = game.wait_for(/EXERCISE COMPLETE/)

    assert_match(/1\.0 · First/, screen)
    assert_match(/1 of 3 cleared/, screen)
    assert_match(/next up: 1\.1 Second/, screen)
  end

  def test_clearing_an_exercise_records_its_time_and_runs
    game = at_first_exercise
    game.wait_for(/not yet/)
    solve('1.0_first', 'one')
    # "run" also appears in the footer, so wait for the screen, not the word.
    screen = game.wait_for(/EXERCISE COMPLETE/)

    assert_match(/\d+s · \d+ runs?/, screen)
  end

  def test_progress_survives_quitting_and_reopening
    game = at_first_exercise
    game.wait_for(/not yet/)
    solve('1.0_first', 'one')
    game.wait_for(/EXERCISE COMPLETE/)
    game.close

    reopened = play
    reopened.wait_for(/1 of 3 exercises cleared/)
    reopened.press(' ')

    assert_match(/EXERCISE 1\.1/, reopened.wait_for(/EXERCISE 1\.1/))
  end

  # ---- the level map -------------------------------------------------------

  def test_m_opens_the_map_and_any_key_closes_it
    game = at_first_exercise
    game.wait_for(/not yet/)
    game.press('m')

    screen = game.wait_for(/LEVEL MAP/)

    assert_match(/LEVEL 1\s+1\.0 1\.1/, screen)
    assert_match(/LEVEL 2\s+2\.0/, screen)
    assert_match(/cleared\s+current\s+locked/, screen)

    game.press(' ')

    assert_match(/EXERCISE 1\.0/, game.wait_for(/EXERCISE 1\.0/))
  end

  # ---- authoring -----------------------------------------------------------

  # A bare level number opens the start of that level.
  def test_author_mode_opens_a_locked_level_directly
    game = play(args: ['--author', '2'])
    game.wait_for(/author mode/)
    game.press(' ')

    screen = game.wait_for(/EXERCISE 2\.0/)

    assert_match(/EXERCISE 2\.0 · Third/, screen)
    assert_match(/\[n\] next/, screen)
  end

  def test_author_mode_opens_one_exercise_by_its_dotted_number
    game = play(args: ['--author', '1.1'])
    game.wait_for(/author mode/)
    game.press(' ')

    assert_match(/EXERCISE 1\.1 · Second/, game.wait_for(/EXERCISE 1\.1/))
  end

  def test_author_mode_steps_between_exercises_without_solving_them
    game = play(args: ['--author', '1'])
    game.wait_for(/author mode/)
    game.press(' ')
    game.wait_for(/EXERCISE 1\.0/)
    game.press('n')
    game.wait_for(/EXERCISE 1\.1/)
    game.press('p')

    assert_match(/EXERCISE 1\.0/, game.wait_for(/EXERCISE 1\.0/))
  end

  # Author mode must not write to the save file.
  def test_author_mode_does_not_write_to_the_save_file
    game = play(args: ['--author', '1'])
    game.wait_for(/author mode/)
    game.press(' ')
    game.wait_for(/not yet/)
    solve('1.0_first', 'one')
    game.wait_for(/EXERCISE COMPLETE/)
    game.close

    save = File.join(@state, Rubites::Progress::FILENAME)
    recorded = File.exist?(save) ? JSON.parse(File.read(save))['solved'] : []

    assert_empty recorded, "author mode recorded progress in #{save}"
  end

  def test_an_exercise_added_while_playing_appears_without_a_restart
    game = at_first_exercise
    game.wait_for(%r{0 / 3})

    write_exercise('2.1_fourth', 'Fourth', expected: 'four', code: 'puts "wrong"')

    assert_match(%r{0 / 4}, game.wait_for(%r{0 / 4}))
  end

  def test_an_exercise_with_no_expected_output_says_so_instead_of_failing
    write_exercise('1.0_first', 'First', expected: nil, code: 'puts "anything"')
    game = at_first_exercise

    assert_match(/no "# Expected output:" line/, game.wait_for(/Expected output/))
  end

  # ---- housekeeping --------------------------------------------------------

  def test_it_survives_an_exercise_file_being_deleted_underneath_it
    game = at_first_exercise
    game.wait_for(/not yet/)

    File.delete(exercise_path('1.0_first'))
    # The next scan re-resolves the current exercise.
    game.wait_for(/EXERCISE 1\.[01]/)

    assert game.alive?, 'deleting the current exercise crashed the game'
  end

  # Needs more than one output row for a misaligned border to show up.
  def test_wide_characters_do_not_bend_the_panels
    # A CJK character is double-width, which covers the same case as a
    # pictograph without putting one in the repository.
    write_exercise('1.0_first', 'First', expected: 'gem',
                                         code: %(puts "ruby 日本語 rocks"\nputs "plain ascii"))
    game = at_first_exercise
    game.wait_for(/plain ascii/)

    # Measured in terminal cells rather than string indices.
    closing = game.columns_of_last('│')

    assert_operator closing.size, :>=, 2, "expected at least two panel rows:\n#{game.text}"
    assert_equal 1, closing.uniq.size,
                 "panel borders drifted to columns #{closing.uniq.inspect}:\n#{game.text}"
  end

  def test_it_reflows_when_the_terminal_is_resized
    game = at_first_exercise
    game.wait_for(/EXERCISE 1\.0/)
    wide = game.columns_of_last('│').first

    game.resize(30, 70)
    game.wait_for(/EXERCISE 1\.0/)
    narrow = game.columns_of_last('│').first

    refute_nil narrow, "nothing rendered after resizing:\n#{game.text}"
    assert_operator narrow, :<, wide, 'panels did not narrow with the terminal'
  end

  def test_it_says_so_rather_than_scribbling_when_the_terminal_is_tiny
    game = at_first_exercise
    game.wait_for(/EXERCISE 1\.0/)
    game.resize(10, 40)

    assert_match(/terminal too small/, game.wait_for(/too small/))
  end

  def test_it_recovers_when_the_terminal_grows_back
    game = at_first_exercise
    game.wait_for(/EXERCISE 1\.0/)
    game.resize(10, 40)
    game.wait_for(/too small/)
    game.resize(34, 92)

    assert_match(/EXERCISE 1\.0/, game.wait_for(/EXERCISE 1\.0/))
  end

  private

    def play(args: [])
      terminal = Rubites::Test::Terminal.new(
        levels_dir: @levels, state_dir: @state, args: args
      )
      @terminals << terminal
      terminal
    end

    def at_first_exercise
      game = play
      game.wait_for(/press any key to begin/)
      game.press(' ')
      game
    end

    def write_exercise(basename, title, expected:, code:, hint: nil)
      number = basename[/\A\d+\.\d+/]
      lines = ["# Exercise #{number}: #{title}", '#', '# Some teaching prose.', '#']
      lines << "# Expected output: #{expected}" if expected
      lines << "# Hint: #{hint}" if hint
      lines += ['', code, '']

      File.write(exercise_path(basename), lines.join("\n"))
    end

    def solve(basename, output)
      path = exercise_path(basename)
      File.write(path, File.read(path).sub(/^puts .*$/, %(puts "#{output}")))
    end

    def exercise_path(basename)
      directory = File.join(@levels, basename[/\A\d+/])
      FileUtils.mkdir_p(directory)
      File.join(directory, "#{basename}.rb")
    end
end
