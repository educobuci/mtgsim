require "test_helper"
require "mtgsim"

class GameStatesTest < MiniTest::Unit::TestCase
  def setup
    @game = Game.new [Player.new, Player.new]
  end
  
  def test_initial_state
    assert_equal :initialized, @game.state
  end
end