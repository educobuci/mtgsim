require "test_helper"
require "mtgsim"

class PhaseStateMachineTest < MiniTest::Unit::TestCase

  def setup
    @game_phase = PhaseStateMachine.new
  end

  def test_untap
    assert_equal :untap, @game_phase.current
  end

  def test_current_phase_is_upkeep_after_untap
    @game_phase.next
    assert_equal :upkeep, @game_phase.current
  end

  def test_next_phase_is_upkeep_after_untap
    assert_equal :upkeep, @game_phase.next
  end

  def test_current_phase_is_untap_after_pass_turn
    12.times { @game_phase.next }
    assert_equal :untap, @game_phase.current
  end

end
