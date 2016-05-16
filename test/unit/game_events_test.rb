require "test_helper"
require "mtgsim"

class GameEventsTest < Minitest::Test
  def setup
    @game = Game.new [Player.new, Player.new]
    @observer = Observer.new
    @game.add_observer @observer
  end
  def teardown
    @game.delete_observers
  end
  
  def test_dices_event
    @game.roll_dices
    assert_equal :dices, @observer.state
    assert_equal 2, @observer.value.size
  end
  def test_start_player
    @game.roll_dices
    @game.start_player @game.die_winner, @game.die_winner
    assert_equal :start_player, @observer.state
    assert_equal @game.die_winner, @observer.value
  end
end

class Observer
  def update(state, value)
    @state = state
    @value = value
  end
  def value
    @value
  end
  def state
    @state
  end
end