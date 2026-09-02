# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/rubites'
require_relative 'support/terminal'

# Drives the real binary in a pty against its own levels, so the game itself is
# covered rather than only the classes underneath it.
class TuiTest < Minitest::Test
  def setup
    @exercises = Dir.mktmpdir('rubites-levels')
    @state = Dir.mktmpdir('rubites-state')
    @terminals = []

    write_level('001_first', 'First', expected: 'one', code: 'puts "wrong"', hint: 'print one')
    write_level('002_second', 'Second', expected: 'two', code: 'puts "wrong"')
    write_level('003_third', 'Third', expected: 'three', code: 'puts "wrong"')
  end

  def teardown
    @terminals.each(&:close)
    FileUtils.remove_entry(@exercises)
    FileUtils.remove_entry(@state)
  end

  # ---- booting -------------------------------------------------------------

  def test_it_opens_on_the_splash_with_the_player_and_the_tally
    game = play

    screen = game.wait_for(/R U B I T E S/)

    assert_match(/Learn to code in Ruby\./, screen)
    assert_match(/tester/, screen)
    assert_match(/0 of 3 levels cleared/, screen)
  end

  def test_any_key_starts_the_first_level
    game = play
    game.wait_for(/press any key to begin/)
    game.press(' ')

    assert_match(/LEVEL 001 · First/, game.wait_for(/LEVEL 001/))
  end

  def test_q_quits_from_the_splash
    game = play
    game.wait_for(/press any key to begin/)
    game.press('q')

    assert game.wait_for_exit, 'q on the splash should quit, not start a level'
  end

  # ---- the level view ------------------------------------------------------

  def test_it_shows_expected_and_actual_side_by_side
    game = at_level_one
    screen = game.wait_for(/not yet/)

    assert_match(/expected/, screen)
    assert_match(/yours/, screen)
    assert_match(/one/, screen)
    assert_match(/wrong/, screen)
  end

  def test_h_toggles_the_hint
    game = at_level_one
    game.wait_for(/not yet/)

    refute_match(/hint: print one/, game.text)

    game.press('h')

    assert_match(/hint: print one/, game.wait_for(/hint: print one/))
  end

  # ---- the thing the panels can't show -------------------------------------

  def test_it_points_at_the_column_where_the_output_diverges
    write_level('001_first', 'First', expected: 'Hello, Rubites!', code: 'puts "Hello, World!"')
    game = at_level_one

    screen = game.wait_for(/differs at column/)

    assert_match(/line 1 differs at column 8/, screen)

    caret = screen.lines.find { |line| line.strip == '^' }

    refute_nil caret, "expected a caret line, screen was:\n#{screen}"
    # Check the caret's column, not just that one was printed.
    yours = screen.lines.find { |line| line.match?(/yours\s+Hello, World!/) }

    assert_equal yours.index('World!'), caret.index('^')
  end

  def test_it_names_a_spacing_difference_rather_than_leaving_it_invisible
    write_level('001_first', 'First', expected: 'a  b', code: 'puts "a b"')
    game = at_level_one

    assert_match(/spacing/, game.wait_for(/spacing/))
  end

  # ---- rerun feedback ------------------------------------------------------

  def test_rerunning_says_so_even_when_nothing_changes
    game = at_level_one
    game.wait_for(/not yet/)
    game.press('r')

    screen = game.wait_for(/same result/)

    assert_match(/reran, run 2, same result/, screen)
  end

  def test_the_run_counter_climbs
    game = at_level_one
    game.wait_for(/not yet/)
    game.press('r')
    game.wait_for(/run 2/)
    game.press('r')

    assert_match(/run 3/, game.wait_for(/run 3/))
  end

  # ---- progression ---------------------------------------------------------

  def test_saving_a_correct_answer_clears_the_level_and_offers_the_next
    game = at_level_one
    game.wait_for(/not yet/)

    solve('001_first', 'one')

    screen = game.wait_for(/LEVEL COMPLETE/)

    assert_match(/001 · First/, screen)
    assert_match(/1 of 3 cleared/, screen)
    assert_match(/next up: level 002 Second/, screen)
  end

  def test_clearing_a_level_records_its_time_and_runs
    game = at_level_one
    game.wait_for(/not yet/)
    solve('001_first', 'one')
    # "run" also appears in the footer, so wait for the screen, not the word.
    screen = game.wait_for(/LEVEL COMPLETE/)

    assert_match(/\d+s · \d+ runs?/, screen)
  end

  def test_progress_survives_quitting_and_reopening
    game = at_level_one
    game.wait_for(/not yet/)
    solve('001_first', 'one')
    game.wait_for(/LEVEL COMPLETE/)
    game.close

    reopened = play
    reopened.wait_for(/1 of 3 levels cleared/)
    reopened.press(' ')

    assert_match(/LEVEL 002/, reopened.wait_for(/LEVEL 002/))
  end

  # ---- the level map -------------------------------------------------------

  def test_m_opens_the_map_and_any_key_closes_it
    game = at_level_one
    game.wait_for(/not yet/)
    game.press('m')

    screen = game.wait_for(/LEVEL MAP/)

    assert_match(/001 002 003/, screen)
    assert_match(/cleared\s+current\s+locked/, screen)

    game.press(' ')

    assert_match(/LEVEL 001/, game.wait_for(/LEVEL 001/))
  end

  # ---- authoring -----------------------------------------------------------

  def test_author_mode_opens_a_locked_level_directly
    game = play(args: ['--author', '3'])
    game.wait_for(/author mode/)
    game.press(' ')

    screen = game.wait_for(/LEVEL 003/)

    assert_match(/LEVEL 003 · Third/, screen)
    assert_match(/\[n\] next/, screen)
  end

  def test_author_mode_steps_between_levels_without_solving_them
    game = play(args: ['--author', '1'])
    game.wait_for(/author mode/)
    game.press(' ')
    game.wait_for(/LEVEL 001/)
    game.press('n')
    game.wait_for(/LEVEL 002/)
    game.press('p')

    assert_match(/LEVEL 001/, game.wait_for(/LEVEL 001/))
  end

  # Author mode must not write to the save file.
  def test_author_mode_does_not_write_to_the_save_file
    game = play(args: ['--author', '1'])
    game.wait_for(/author mode/)
    game.press(' ')
    game.wait_for(/not yet/)
    solve('001_first', 'one')
    game.wait_for(/LEVEL COMPLETE/)
    game.close

    save = File.join(@state, Rubites::Progress::FILENAME)
    recorded = File.exist?(save) ? JSON.parse(File.read(save))['solved'] : []

    assert_empty recorded, "author mode recorded progress in #{save}"
  end

  def test_a_level_added_while_playing_appears_without_a_restart
    game = at_level_one
    game.wait_for(%r{0 / 3})

    write_level('004_fourth', 'Fourth', expected: 'four', code: 'puts "wrong"')

    assert_match(%r{0 / 4}, game.wait_for(%r{0 / 4}))
  end

  def test_a_level_with_no_expected_output_says_so_instead_of_failing
    write_level('001_first', 'First', expected: nil, code: 'puts "anything"')
    game = at_level_one

    assert_match(/no "# Expected output:" line/, game.wait_for(/Expected output/))
  end

  # ---- housekeeping --------------------------------------------------------

  def test_it_survives_a_level_file_being_deleted_underneath_it
    game = at_level_one
    game.wait_for(/not yet/)

    File.delete(File.join(@exercises, '001_first.rb'))
    # The next scan re-resolves the current level.
    game.wait_for(/LEVEL 00[12]/)

    assert game.alive?, 'deleting the current level crashed the game'
  end

  # Needs more than one output row for a misaligned border to show up.
  def test_wide_characters_do_not_bend_the_panels
    # A CJK character is double-width, which covers the same case as a
    # pictograph without putting one in the repository.
    write_level('001_first', 'First', expected: 'gem',
                                      code: %(puts "ruby 日本語 rocks"\nputs "plain ascii"))
    game = at_level_one
    game.wait_for(/plain ascii/)

    # Measured in terminal cells rather than string indices.
    closing = game.columns_of_last('│')

    assert_operator closing.size, :>=, 2, "expected at least two panel rows:\n#{game.text}"
    assert_equal 1, closing.uniq.size,
                 "panel borders drifted to columns #{closing.uniq.inspect}:\n#{game.text}"
  end

  def test_it_reflows_when_the_terminal_is_resized
    game = at_level_one
    game.wait_for(/LEVEL 001/)
    wide = game.columns_of_last('│').first

    game.resize(30, 70)
    game.wait_for(/LEVEL 001/)
    narrow = game.columns_of_last('│').first

    refute_nil narrow, "nothing rendered after resizing:\n#{game.text}"
    assert_operator narrow, :<, wide, 'panels did not narrow with the terminal'
  end

  def test_it_says_so_rather_than_scribbling_when_the_terminal_is_tiny
    game = at_level_one
    game.wait_for(/LEVEL 001/)
    game.resize(10, 40)

    assert_match(/terminal too small/, game.wait_for(/too small/))
  end

  def test_it_recovers_when_the_terminal_grows_back
    game = at_level_one
    game.wait_for(/LEVEL 001/)
    game.resize(10, 40)
    game.wait_for(/too small/)
    game.resize(34, 92)

    assert_match(/LEVEL 001/, game.wait_for(/LEVEL 001/))
  end

  private

    def play(args: [])
      terminal = Rubites::Test::Terminal.new(
        exercises_dir: @exercises, state_dir: @state, args: args
      )
      @terminals << terminal
      terminal
    end

    def at_level_one
      game = play
      game.wait_for(/press any key to begin/)
      game.press(' ')
      game
    end

    def write_level(basename, title, expected:, code:, hint: nil)
      number = basename[/\A\d+/]
      lines = ["# Level #{number}: #{title}", '#', '# Some teaching prose.', '#']
      lines << "# Expected output: #{expected}" if expected
      lines << "# Hint: #{hint}" if hint
      lines += ['', code, '']

      File.write(File.join(@exercises, "#{basename}.rb"), lines.join("\n"))
    end

    def solve(basename, output)
      path = File.join(@exercises, "#{basename}.rb")
      File.write(path, File.read(path).sub(/^puts .*$/, %(puts "#{output}")))
    end
end
