class Game
  attr_reader :phase

  def initialize(players, phase_manager=PhaseStateMachine.new)
    @players = players
    
    @phase_manager = phase_manager
    @phase_manager.add_observer self
  end
  
  def start

    @players[0].id = :player1
    @players[0].library = @players[0].deck.shuffle.dup

    @players[1].id = :player2
    @players[1].library = @players[1].deck.shuffle.dup
    
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
    
    unless p.hand[card].kind_of? Cards::Land
      return false 
    end
    
    p.battlefield << p.hand.slice!(card)
    
    true
  end
  def tap_card(card, player=@current_player_index)
    p = @players[player]
    c = p.battlefield[card]
    #c.tap_card
    
    if c.kind_of? Cards::Land
      p.mana_pool[c.color] += 1
    end
  end
  def players(index)
    @players[index]
  end
  # PHASES
  
  def next_phase
    @phase_manager.next
  end

  def update(status, phase)
    if phase == :pass_turn
      if @current_player_index == 1
        @current_player_index = 0
      else
        @current_player_index = 1
      end
    end
  end

  def turn
    @phase = :untap
  end
  def untap
    self.current_player.battlefield.each {|c| c.untap_card}
    @phase = :upkeep
  end
  def draw
    self.draw_card
    @phase = :main
  end
end
