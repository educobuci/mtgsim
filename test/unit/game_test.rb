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
  
  def test_tap_land_to_add_a_mana_to_pool
    game_start()
    
    land_index = @game.current_player.hand.index { |c| c.kind_of? Cards::Land }
    @game.play_card land_index
    
    @game.tap_card 0
    assert_equal 1, @game.current_player.mana_pool[:blue]
  end
  
  def test_mana_cost
    game_start()
    @game.current_player.hand = [Cards::SnapcasterMage.new]
    refute @game.play_card(0)
    
    2.times { @game.current_player.battlefield << Cards::Island.new }
    
    @game.tap_card 0
    @game.tap_card 1

    assert @game.play_card(0)
  end
  
  def test_land_play
    game_start()
    @game.current_player.hand = [Cards::Island.new, Cards::Island.new]
    assert @game.play_card(0)
    refute @game.play_card(0)
  end

  def test_game_untap_phase
    players = create_players

    players[0].battlefield << Cards::Island.new
    players[0].battlefield << Cards::SnapcasterMage.new

    players[0].battlefield.each { |c| c.tap_card }

    game = Game.new players

    game.start
    game.untap

    refute players[0].battlefield[0].is_tapped?
    refute players[0].battlefield[1].is_tapped?
  end

  def test_game_next_phase
    phase_manager_mock = MiniTest::Mock.new
    phase_manager_mock.expect :next, nil

    game = Game.new create_players, phase_manager_mock
    game.next_phase

    phase_manager_mock.verify
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
