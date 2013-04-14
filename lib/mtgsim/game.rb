class Game
  attr_reader :phase, :current_player_index, :die_winner, :priority_player, :phase_manager

  def initialize(players, phase_manager=PhaseStateMachine.new)
    @players = players
    @land_fall = false
    
    @phase_manager = phase_manager
    @phase_manager.add_observer self
    self.state = :initialized
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
      3.times { self.next_phase }
      self.draw_card(@current_player_index)
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
  
  def hand(player)
    @players[player].hand
  end
  
  def draw_card(player, count=1)
    count.times do
      p = @players[player]
      p.hand << p.library.pop
    end
  end
  
  def play_card(player, card)
    check_state :started do
      if player == @current_player_index
        p = @players[player]
        
        if p.hand[card].kind_of?(Cards::Land)
          check_phase [:first_main, :second_main] do
            unless @land_fall
              p.board << p.hand.slice!(card)
              @land_fall = true
              return true
            end
          end
        elsif p.mana_pool.pay_cost(p.hand[card])
          check_phase [:first_main, :second_main] do
            p.board << p.hand.slice!(card)
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
      c.tap_card
    
      if c.kind_of? Cards::Land
        p.mana_pool.add c.color
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
        if @priority_player == @current_player_index
          self.next_phase
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
    self.current_player.board.each { |c| c.untap_card }
  end
  
  def state
    @state
  end
  
  def state=(value)
    @state = value
  end
end
