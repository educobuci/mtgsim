require "test_helper"
require "mtgsim"

class GameTest < MiniTest::Unit::TestCase
  def setup
    @game = Game.new
    @game.start
  end
  
  def test_simple_game_start
    @game.current_player_index = 0
    assert_equal @game.current_player.hand.size, 7
    
    @game.turn
    @game.untap
    @game.draw
    assert_equal @game.hand.size, 8
    assert_equal @game.current_player.library.size, 52
    
    @game.hand.each do |card|
      #puts card.name
    end
  end
  
  def test_game_phases
    @game.current_player_index = 0

    @game.turn
    assert_equal @game.phase, :untap

    @game.untap
    assert_equal @game.phase, :upkeep
    
    @game.draw
    assert_equal @game.phase, :main
  end
  
  def test_card_play
    @game.current_player_index = 0
    @game.turn
    @game.untap
    @game.draw
    
    land_index = @game.current_player.hand.index { |c| c.kind_of? Cards::Land }
    @game.play land_index
    
    assert_equal @game.hand.size, 7
    assert_equal @game.current_player.battlefield.size, 1
  end
end