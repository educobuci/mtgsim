require "test_helper"
require "mtgsim"

class GameStatesTest < MiniTest::Unit::TestCase
  def setup
    @game = Game.new [Player.new, Player.new]
  end
  
  def test_initial_state
    assert_equal :initialized, @game.state
  end
  
  def test_dices_roll
    result = @game.roll_dices
    assert_equal :dices, @game.state
    
    assert_includes (1..6), result[0]
    assert_includes (1..6), result[1]
    
    refute_equal result[0], result[1]
  end
  
  def test_die_roll_winner_starting
    result = @game.roll_dices
    
    @game.start(@game.die_winner, @game.die_winner)
    assert_equal :start, @game.state

    assert_equal @game.die_winner, @game.current_player_index
  end
  
  def test_die_roll_winner_not_start
    result = @game.roll_dices
    winner = @game.die_winner
    loser = @game.die_winner == 0 ? 1 : 0
    
    @game.start(winner, loser)
    assert_equal :start, @game.state

    assert_equal loser, @game.current_player_index
  end
  
  def test_die_roll_loser_cant_decide
    result = @game.roll_dices
    winner = @game.die_winner
    loser = @game.die_winner == 0 ? 1 : 0
    
    @game.start(loser, loser)
    refute_equal :start, @game.state

    assert_nil @game.current_player_index
  end  
  
  def test_game_can_start_only_once
    @game.roll_dices
    loser = @game.die_winner == 0 ? 1 : 0
    
    @game.start(@game.die_winner, loser)    
    @game.start(@game.die_winner, @game.die_winner)
    
    refute_equal @game.die_winner, @game.current_player_index
  end
  
  def test_hand
    @game.roll_dices
    @game.start(@game.die_winner, @game.die_winner)
    @game.draw_hands
    assert_equal 7, @game.players(0).hand.size
    assert_equal 7, @game.players(1).hand.size
    assert_equal :hand, @game.state
  end
  
  def test_keep
    @game.roll_dices
    @game.start(@game.die_winner, @game.die_winner)
    @game.draw_hands
    
    @game.keep(0)
    assert_equal :hand, @game.state
    @game.keep(1)
    assert_equal :keep, @game.state
  end
  
  def test_keep_only_on_hand
    assert_equal :initialized, @game.state
    @game.keep(0)
    @game.keep(1)
    refute_equal :keep, @game.state
  end
  
  def test_mulligan
    @game.roll_dices
    @game.start(@game.die_winner, @game.die_winner)
    @game.draw_hands
    @game.mulligan(0)
    assert_equal 6, @game.players(0).hand
  end
  
end