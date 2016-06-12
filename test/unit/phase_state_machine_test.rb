require "test_helper"
require "mtgsim"

class PhaseStateMachineTest < Minitest::Test

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

  def test_phase_state_can_have_observers_to_be_called_on_phase_change
    phaseObserver = PhaseObserverFake.new

    @game_phase.add_observer phaseObserver
    @game_phase.next

    assert_equal :upkeep, phaseObserver.phase
  end

  private

  class PhaseObserverFake

    def phase
      @phase
    end

    def update(status, phase)
      @phase = phase
    end
  end

end
