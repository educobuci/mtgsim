class Game
  attr_reader :phase, :current_player_index

  def initialize(players, phase_manager=PhaseStateMachine.new)
    @players = players
    @land_fall = false
    
    @phase_manager = phase_manager
    @phase_manager.add_observer self
    self.state = :initialized
  end
  def start
    @players[0].id = :player1
    @players[0].library = @players[0].deck.shuffle.dup

    @players[1].id = :player2
    @players[1].library = @players[1].deck.shuffle.dup
    
    #self.roll_dices()
    
    #each player sould draw seven cards
    self.draw_card 0, 7
    self.draw_card 1, 7
    
    @current_player_index = 0
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
  # PHASES
  
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
  
  def dices_result
    
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
  
  private
  
  def state=(value)
    @state = value
  end
  
  def roll_dices
    # @dices_result = []
    # 
    # result = rand(0..1)
    # 
    # if result == 0
    #   @dices_result[0] = rand(1..)
    # end
    #  = 
    # @dices_result[1] = rand(1..6)
  end
end
