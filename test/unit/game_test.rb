require "test_helper"
require "mtgsim"

class GameTest < MiniTest::Unit::TestCase
  def setup
    @game = Game.new
    @game.start
  end
  
  def test_simple_game_start
    @game.current_player_index = 0
    assert_equal 7, @game.current_player.hand.size
    
    game_start()
    
    assert_equal 8, @game.current_player.hand.size
    assert_equal 52, @game.current_player.library.size
    
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
    game_start()
    
    land_index = @game.current_player.hand.index { |c| c.kind_of? Cards::Land }
    @game.play_card land_index
    
    assert_equal 7, @game.hand.size
    assert_equal 1, @game.current_player.battlefield.size
    refute @game.current_player.hand.include?(@game.current_player.battlefield.first)
  end
  
  def test_mana_pool
    game_start()
    
    land_index = @game.current_player.hand.index { |c| c.kind_of? Cards::Land }
    @game.play_card land_index
    
    @game.tap_card 0
    assert_equal [ blue: 1 ], @game.current_player.mana_pool
  end
  
  private
  
  def game_start
    @game.current_player_index = 0
    @game.turn
    @game.untap
    @game.draw
  end
end