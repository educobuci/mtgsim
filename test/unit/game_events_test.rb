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
  def start_game
    @game.roll_dices
    @game.start_player @game.die_winner, @game.die_winner
    @game.draw_hands
    @game.keep @game.die_winner
    die_loser = @game.die_winner == 0 ? 1 : 0
    @game.keep die_loser
    @game.start
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
  def test_keep
    @game.roll_dices
    @game.start_player @game.die_winner, @game.die_winner
    @game.draw_hands
    @game.keep(@game.die_winner)
    die_loser = @game.die_winner == 0 ? 1 : 0
    assert_equal :keep, @observer.state
    assert_equal @game.die_winner, @observer.value
    @game.keep(die_loser)
    assert_equal :keep, @observer.state
    assert_equal die_loser, @observer.value
  end
  def test_muligan
    @game.roll_dices
    @game.start_player @game.die_winner, @game.die_winner
    @game.draw_hands
    @game.mulligan(@game.die_winner)
    assert_equal :mulligan, @observer.state
    assert_equal @game.die_winner, @observer.value[0]
    assert_equal 1, @observer.value[1]
  end
  def test_game_start
    start_game
    assert_equal :changed_phase, @observer.state
    assert_equal :first_main, @observer.value
  end
  def test_phase_pass
    start_game
    @game.pass(@game.current_player_index)
    assert_equal :pass, @observer.state
    assert_equal @game.current_player_index, @observer.value
  end
  def test_play_card
    start_game
    island = Cards::Island.new
    @game.current_player.hand = [island]
    @game.play_card(@game.current_player_index, 0)
    assert_equal :play_card, @observer.state
    assert_equal @game.current_player_index, @observer.value[0]
    assert_equal island, @observer.value[1]
  end
end

class Observer
  def update(state, *args)
    @state = state
    @value = args.size == 1 ? args[0] : args
  end
  def value
    @value
  end
  def state
    @state
  end
end