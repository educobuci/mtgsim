class Game
  attr_reader :phase
  attr_accessor :current_player_index
  
  def start
    player1 = Player.new
    player1.library = player1.deck.shuffle.dup
    
    player2 = Player.new
    player2.library = player2.deck.shuffle.dup
    
    @players = [player1, player2]
    
    #each player sould draw seven cards
    self.draw_card 0, 7
    self.draw_card 1, 7
  end
  def current_player
    @players[current_player_index]
  end
  def hand(player=current_player_index)
    @players[player].hand
  end
  def draw_card(player=current_player_index, count=1)
    count.times do
      p = @players[player]
      p.hand << p.library.pop
    end
  end
  def play_card(card, player=current_player_index)
    p = @players[player]
    
    unless p.hand[card].kind_of? Cards::Land
      return false 
    end
    
    p.battlefield << p.hand.slice!(card)
    
    true
  end
  def tap_card(card, player=current_player_index)
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
  def turn
    @phase = :untap
  end
  def untap
    @phase = :upkeep
  end
  def draw
    self.draw_card
    @phase = :main
  end
end