class Game
  attr_reader :phase, :current_player_index, :die_winner

  def initialize(players, phase_manager=PhaseStateMachine.new)
    @players = players
    @land_fall = false
    
    @phase_manager = phase_manager
    @phase_manager.add_observer self
    self.state = :initialized
  end
  
  def start(player_index, start_index)
    check_state :dices do
      if @die_winner == player_index
        self.state = :start
        @current_player_index = start_index
      end
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
  
  def hand(player=@current_player_index)
    @players[player].hand
  end
  
  def draw_card(player=@current_player_index, count=1)
    count.times do
      p = @players[player]
      p.hand << p.library.pop
    end
  end
  
  def play_card(card, player=@current_player_index)
    p = @players[player]
    
    if p.hand[card].kind_of?(Cards::Land)
      unless @land_fall
        p.battlefield << p.hand.slice!(card)
        @land_fall = true
      end
    elsif p.mana_pool.pay_cost(p.hand[card])
      p.battlefield << p.hand.slice!(card)
    else
      return false
    end
  end
  
  def tap_card(card, player=@current_player_index)
    p = @players[player]
    c = p.battlefield[card]
    c.tap_card
    
    if c.kind_of? Cards::Land
      p.mana_pool.add c.color
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

  def update(status, phase)
    if phase == :pass_turn
      if @current_player_index == 1
        @current_player_index = 0
      else
        @current_player_index = 1
      end
      @land_fall = false
    end
  end
  
  def roll_dices
    self.state = :dices
    
    dices_result = []
    
    @die_winner = rand(0..1)
        
    dices_result[@die_winner] = rand(2..6)
    
    dices_result[(@die_winner == 0 ? 1 : 0)] = rand(2..dices_result[@die_winner]) - 1
    
    dices_result
  end

  def turn
    @phase = :untap
    @land_fall = false
  end
  
  def untap
    self.current_player.battlefield.each {|c| c.untap_card}
    @phase = :upkeep
  end
  
  def draw
    self.draw_card
    @phase = :main
  end
  
  def ready(index)
    @players[index].ready = true
    if @players.count {|p| p.ready == true } == 2
      self.state = :ready
    end
  end
  
  def state
    @state
  end
  
  def state=(value)
    @state = value
  end  
end
