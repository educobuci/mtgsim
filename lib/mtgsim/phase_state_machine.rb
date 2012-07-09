require 'observer'

class PhaseStateMachine
  include Observable

  def initialize
    @phases = configure_phases
    @current_phase = :untap
  end

  def current
    @current_phase
  end

  def next
    @current_phase = @phases[@current_phase]
    changed
    notify_observers(:changed_phase, @current_phase)

    @current_phase
  end

  private
  def configure_phases
    { :untap => :upkeep,
      :upkeep => :draw,
      :draw => :first_main,
      :first_main => :attack,
      :attack => :attackers,
      :attackers => :blockers,
      :blockers => :damage,
      :damage => :end_attack,
      :end_attack => :second_main,
      :second_main => :end,
      :end => :pass_turn,
      :pass_turn => :untap }
  end

end
