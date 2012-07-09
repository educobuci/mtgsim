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

  def test_phase_state_can_have_observers_to_be_called_on_phase_change
    phaseObserver = PhaseObserverFake.new
    assert_equal false, phaseObserver.wasNotified

    @game_phase.add_observer phaseObserver
    @game_phase.next

    assert_equal true, phaseObserver.wasNotified
  end

  private

  class PhaseObserverFake

    def initialize
      @notified = false
    end

    def wasNotified
      @notified
    end

    def update(status, phase)
      @notified = true
    end
  end

end
