class Game
  attr_reader :phase, :current_player_index, :die_winner, :priority_player, :phase_manager, :attackers, :blockers, :winner

  def initialize(players, phase_manager=PhaseStateMachine.new)
    @players = players
    @land_fall = false
    
    @phase_manager = phase_manager
    @phase_manager.add_observer self
    self.state = :initialized
    @tapped_to_cast = []
    @attackers = []
    @blockers = {}
  end
  
  def start_player(player_index, start_index)
    check_state :dices do
      if @die_winner == player_index
        self.state = :start_player
        @current_player_index = start_index
      end
    end
  end
  
  def start
    check_state :keep do
      self.state = :started
      self.phase_manager.jump_to :first_main
    end
  end
  
  def check_state(value, &block)
    if self.state == value
      yield block
    end
  end
  
  def draw_hands
    (0..1).each do |p|
      @players[p].library = @players[p].deck.shuffle.dup
      self.draw_card p, 7
    end
    self.state = :hand
  end
  
  def keep(player_index)
    check_state :hand do
      @players[player_index].keep = true
      if @players.count {|p| p.keep == true } == 2
        self.state = :keep
      end      
    end
  end
  
  def mulligan(player_index)
    check_state :hand do
      player = players(player_index)
      unless player.keep
        player.mulligan += 1
        player.library = player.library.shuffle
        player.hand = []
        self.draw_card player_index, 7 - player.mulligan
      end
    end
  end
  
  def current_player
    @players[@current_player_index]
  end
  
  def opponent_player
    @players[opponent_index]
  end
  
  def opponent_index
    @current_player_index == 0 ? 1 : 0
  end
  
  def hand(player)
    @players[player].hand
  end
  
  def draw_card(player, count=1)
    count.times do
      p = @players[player]
      p.hand << p.library.pop
    end
  end
  
  def play_card(player, card_index)
    check_state :started do
      if player == @current_player_index
        p = @players[player]
        
        if p.hand[card_index].kind_of?(Cards::Land)
          check_phase [:first_main, :second_main] do
            unless @land_fall
              p.board << p.hand.slice!(card_index)
              @land_fall = true
              return true
            end
          end
        elsif p.mana_pool.pay_cost(p.hand[card_index])
          check_phase [:first_main, :second_main] do
            card = p.hand.slice!(card_index)
            card.sickness = true if card.kind_of?(Cards::Creature)
            p.board << card
            @tapped_to_cast = []
            return true
          end
        end
      end
    end
    
    return false
  end
  
  def tap_card(player, card)
    check_state :started do
      p = @players[player]
      c = p.board[card]
      unless c.is_tapped?
        c.tap_card
        if c.kind_of? Cards::Land
          @tapped_to_cast << c
          p.mana_pool.add c.color
        end
      end
    end
  end
  
  def attack(player, card_index)
    check_phase :attackers do
      card = @players[player].board[card_index]
      if !card.nil? && card.kind_of?(Cards::Creature)
        unless @attackers.include?(card)
          if !card.sickness
            @attackers.push(card)
            card.tap_card()
          end
        else
          @attackers.delete(card)
          card.untap_card_card()
        end
      else
      end
    end
  end
  
  def block(player, attacker_index, blocker_index)
    check_phase :blockers do
      attack_player = player == 0 ? 1 : 0
      attacker = @players[attack_player].board[attacker_index]
      blocker = @players[player].board[blocker_index]
      
      if  !blocker.nil? && blocker.kind_of?(Cards::Creature) &&
          !attacker.nil? && attacker.kind_of?(Cards::Creature) &&
          @attackers.include?(attacker)
          
        unless @blockers.include?(blocker)
          @blockers[blocker] = attacker
        else
          @blockers.delete(blocker)
        end
        
      end
    end
  end
  
  def players(index)
    @players[index]
  end
  
  def next_phase
    @phase_manager.next
  end
  
  def current_phase
    @phase_manager.current
  end
  
  def roll_dices
    self.state = :dices
    dices_result = []
    
    @die_winner = rand(0..1)
    dices_result[@die_winner] = rand(2..6)
    dices_result[(@die_winner == 0 ? 1 : 0)] = rand(2..dices_result[@die_winner]) - 1
    
    dices_result
  end
  
  def pass(player)
    check_state :started do
      if @priority_player == player
        @priority_player = player == 0 ? 1 : 0
        if self.current_phase == :blockers
          if @priority_player != @current_player_index
            self.next_phase
          end
        else
          if @priority_player == @current_player_index
            self.next_phase
          end
        end
        return true
      end
    end
    return false
  end
  
  def check_phase(phases, &block)
    if phases.kind_of? Array
      if phases.include?(self.current_phase)
        yield block
      end
    else
      if phases == self.current_phase
        yield block
      end
    end
  end

  def update(status, phase)
    @priority_player = @current_player_index
    if phase == :untap
      self.turn
      self.untap
      self.next_phase
    elsif phase == :draw
      self.draw_card @current_player_index
      self.next_phase
    elsif phase == :blockers
      @priority_player = self.opponent_index
    elsif phase == :damage
      non_blocked = @attackers.select{|attacker| !@blockers.has_value?(attacker)}
      self.players(self.opponent_index).life -= non_blocked.inject(0){ |damage, c| damage + [0, c.power].max }
    elsif phase == :end_combat
      @attacker = []
    end
    if self.players(0).life <= 0 || self.players(1).life <= 0
      self.state = :ended
      @winner = self.players(0).life > 0 ? 0 : 1
    end
  end
  
  def turn
    if @current_player_index == 1
      @current_player_index = 0
    else
      @current_player_index = 1
    end
    @land_fall = false
  end
  
  def untap
    self.current_player.board.each do |c|
      c.untap_card
      c.sickness = false if c.kind_of? Cards::Creature
    end
  end
  
  def state
    @state
  end
  
  def state=(value)
    @state = value
  end
  
  def cancel_cast(player)
    @tapped_to_cast.each do |c|
      c.untap_card
      @players[player].mana_pool.remove c.color
    end
  end
end
