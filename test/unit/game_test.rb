require "test_helper"
require "mtgsim"

class GameTest < MiniTest::Unit::TestCase
  def setup
    @game = Game.new create_players
    @game.start
  end
  
  def test_simple_game_start
    assert_equal 7, @game.current_player.hand.size
    
    game_start()
    
    assert_equal 8, @game.current_player.hand.size
    assert_equal 52, @game.current_player.library.size
    
    @game.hand.each do |card|
      #puts card.name
    end
  end
  
  def test_game_phases

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
    assert_equal({ black:0, blue: 1, green: 0, red: 0, white: 0 }, @game.current_player.mana_pool)
  end

  def test_game_untap_phase

    players = create_players

    players[0].battlefield << Cards::Island.new
    players[0].battlefield << Cards::Snapcaster.new

    players[0].battlefield.each { |c| c.tap_card }

    game = Game.new players

    game.start
    game.untap

    assert_equal false, players[0].battlefield[0].is_tapped?
    assert_equal false, players[0].battlefield[1].is_tapped?
  end
  
  private

  def create_players
    [Player.new, Player.new]
  end
  
  def game_start
    @game.turn
    @game.untap
    @game.draw
  end
end
