require "test_helper"
require "mtgsim"

class GameTest < MiniTest::Unit::TestCase
  def setup
    @game = Game.new
    @game.start
  end
  
  def test_simple_game_start
    @game.current_player = 0
    assert_equal @game.hand.size, 7
    
    @game.turn
    @game.untap
    @game.draw
    assert_equal @game.hand.size, 8
    assert_equal @game.players[@game.current_player].library.size, 52
    
    @game.hand.each do |card|
      #puts card.name
    end
  end
  
  def test_game_phases
    @game.current_player = 0

    @game.turn
    assert_equal @game.phase, :untap

    @game.untap
    assert_equal @game.phase, :upkeep
    
    @game.draw
    assert_equal @game.phase, :main
  end
end