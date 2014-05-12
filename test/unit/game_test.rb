require "test_helper"
require "mtgsim"

class GameTest# < Minitest::Test
  def setup
    @game = Game.new create_players
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
    phase_manager_mock.expect :add_observer, nil, [Game]
    
    game = Game.new create_players, phase_manager_mock

    game.next_phase

    phase_manager_mock.verify
  end

  def test_game_change_to_player_2_after_player_1_has_played 
    assert_equal :player1, @game.current_player.id
    11.times { @game.next_phase }
    assert_equal :player2, @game.current_player.id
  end

  def test_game_change_back_to_player_1_after_player_2_has_played 
    assert_equal :player1, @game.current_player.id
    11.times { @game.next_phase }
    assert_equal :player2, @game.current_player.id
    12.times { @game.next_phase }
    assert_equal :player1, @game.current_player.id
  end
end
