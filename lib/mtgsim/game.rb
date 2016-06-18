require 'observer'

class Game
  include Observable
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
    (0..1).each do |p|
      @players[p].library = @players[p].deck.shuffle.dup
    end
  end
  
  def start_player(player_index, start_index)
    check_state :dices do
      if @die_winner == player_index
        self.state = :start_player
        @current_player_index = start_index
        changed
        notify_observers :start_player, start_index
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
      self.draw_card p, 7
    end
    self.state = :hand
  end
  
  def keep(player_index)
    check_state :hand do
      @players[player_index].keep = true
      changed
      notify_observers :keep, player_index
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
        player.library = (player.library + player.hand).shuffle
        player.hand = []
        self.draw_card player_index, 7 - player.mulligan
        changed
        notify_observers :mulligan, player_index, player.mulligan
      end
    end
  end
  
  def current_player
    @players[@current_player_index]
  end
  
  def opponent_player
    @players[self.opponent_index()]
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
        played_card = nil
        if current_player.hand[card_index].kind_of?(Cards::Land)
          check_phase [:first_main, :second_main] do
            unless @land_fall
              played_card = current_player.hand.slice!(card_index)
              current_player.board << played_card
              @land_fall = true
            end
          end
        elsif current_player.mana_pool.pay_cost(current_player.hand[card_index])
          check_phase [:first_main, :second_main] do
            played_card = current_player.hand.slice!(card_index)
            if played_card.kind_of?(Cards::Creature)
              played_card.sickness = true 
              played_card.damage = 0
              played_card.dealt_damage = 0
            end
            current_player.board << played_card
            @tapped_to_cast = []
          end
        end
        unless played_card.nil?
          changed
          notify_observers :play_card, player, played_card
          return true
        end
      end
    end
    
    return false
  end
  
  def tap_card(player_index, card)
    check_state :started do
      p = players(player_index)
      c = p.board[card]
      unless c.is_tapped?
        c.tap_card
        if c.kind_of? Cards::Land
          @tapped_to_cast << c
          p.mana_pool.add c.color
        end
        changed
        notify_observers :tap_card, player_index, card
      end
    end
  end
  
  def attack(player_index, card_index)
    check_phase :attackers do
      card = players(player_index).board[card_index]
      if !card.nil? && card.kind_of?(Cards::Creature)
        unless @attackers.include?(card)
          if !card.sickness
            @attackers.push(card)
            card.tap_card()
            changed
            notify_observers :attack, player_index, card_index
          end
        else
          @attackers.delete(card)
          card.untap_card()
        end
      else
      end
    end
  end
  
  def block(player_index, attacker_index, blocker_index)
    check_phase :blockers do
      attack_player = player_index == 0 ? 1 : 0
      attacker = players(attack_player).board[attacker_index]
      blocker = players(player_index).board[blocker_index]
      
      if  !blocker.nil? && blocker.kind_of?(Cards::Creature) &&
          !attacker.nil? && attacker.kind_of?(Cards::Creature) &&
          @attackers.include?(attacker)
          
        unless @blockers.include?(blocker)
          @blockers[blocker] = attacker
          changed
          notify_observers :block, attacker_index, blocker_index
        else
          @blockers.delete(blocker)
        end
        
      end
    end
  end
  
  def assign_damage(player_index, damage_assignment = nil)
    player = players(player_index)
    opponent = players(player_index == 0 ? 1 : 0)
    check_phase :damage do
      if damage_assignment
        damage_cards_assigment = damage_assignment.keys.inject({}) do |attackers,attacker|
          attackers[player.board[attacker]] = damage_assignment[attacker].keys.inject({}) do |blockers,blocker|
            blockers[opponent.board[blocker]] = damage_assignment[attacker][blocker]
            blockers
          end
          attackers
        end
        self.calculate_combat_damage(damage_cards_assigment)
      else
        self.calculate_combat_damage(nil)
      end
      changed
      notify_observers :assign_damage, damage_assignment
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
    
    changed
    notify_observers :dices, dices_result
    
    dices_result
  end
  
  def pass(player_index)
    check_state :started do
      if @priority_player == player_index
        changed
        @priority_player = player_index == 0 ? 1 : 0
        notify_observers :pass, player_index
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
    changed
    notify_observers status, phase
    case phase
    when :untap
      self.turn
      self.untap
      self.next_phase
    when :draw
      self.draw_card @current_player_index
    when :blockers
      @priority_player = self.opponent_index
      changed
      notify_observers status, phase
    when :damage
      multipleBlocks = @blockers.keys.inject({}) do |block_sum,blocker|
        block_sum[@blockers[blocker]] = (block_sum[@blockers[blocker]] || 0) + 1
        block_sum
      end
      unless multipleBlocks.values.any?{|v| v > 1}
        self.calculate_combat_damage
      end
    when :end_combat
      @attackers = []
      @blockers = {}
    when :cleanup
      self.next_phase
    end
    if self.players(0).life <= 0 || self.players(1).life <= 0
      self.state = :ended
      @winner = self.players(0).life > 0 ? 0 : 1
    end
  end
  
  def calculate_combat_damage(damage_assignment=nil)
    non_blocked = @attackers.select{|attacker| !@blockers.has_value?(attacker)}
    opponent_player.life -= non_blocked.inject(0){ |damage, c| damage + [0, c.power].max }
    @blockers.each do |blocker, attacker|
      if @blockers.map{ |k, v| v == attacker ? k : nil }.compact.size > 1
        if damage_assignment
          if damage_assignment[attacker].has_key?(blocker)
            blocker_damage = damage_assignment[attacker][blocker]
          else
            blocker_damage = 0
          end
        else
          blocker_damage = [attacker.power - attacker.dealt_damage, blocker.toughness].min
        end
      else
        blocker_damage = attacker.power
      end
      blocker.damage += blocker_damage
      attacker.dealt_damage += blocker_damage
    
      attacker.damage += [blocker.power, attacker.toughness].min
    end
    deaths = {0 => [], 1 => []}
    @players.each_with_index do |p,index|
      dead_creatures = p.board.select do |c|
        c.kind_of?(Cards::Creature) && c.damage >= c.toughness
      end
      deaths[index] = dead_creatures.map { |c| p.board.find_index(c) }
      p.graveyard += dead_creatures
      p.board -= dead_creatures
    end
    if deaths[0].size > 0 || deaths[1].size > 0
      changed
      notify_observers :creature_die, deaths
    end
  end
  
  def turn
    if @current_player_index == 1
      @current_player_index = 0
    else
      @current_player_index = 1
    end
    self.current_player.board.each {|c| c.damage = 0 if c.kind_of? Cards::Creature }
    self.opponent_player.board.each {|c| c.damage = 0 if c.kind_of? Cards::Creature }
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
