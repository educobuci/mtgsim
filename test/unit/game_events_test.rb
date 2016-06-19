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
    @player = @game.current_player_index
    @opponent = @game.current_player_index == 0 ? 1 : 0
  end
  def prepare_board_to_attack(attackers, blockers)
    attackers.each do |attacker|
      attacker.damage = 0
      attacker.dealt_damage = 0
    end
    @game.players(@player).board += attackers
    
    blockers.each do |blocker|
      blocker.damage = 0
      blocker.dealt_damage = 0
    end
    @game.players(@opponent).board += blockers
    
    @attackers = attackers
    @blockers = blockers
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
  def test_tap_card
    start_game
    island = Cards::Island.new
    @game.current_player.hand = [island]
    @game.play_card(@game.current_player_index, 0)
    @game.tap_card(@game.current_player_index, 0)
    assert_equal :tap_card, @observer.state
    assert_equal @game.current_player_index, @observer.value[0]
    assert_equal 0, @observer.value[1]
  end
  def test_attack
    start_game
    prepare_board_to_attack [Cards::DelverofSecrets.new, Cards::GeistofSaintTraft.new], []
    @game.phase_manager.jump_to :attackers
    @game.attack @player, 0
    assert_equal :attack, @observer.state
    assert_equal @player, @observer.value[0]
    assert_equal 0, @observer.value[1]
    @game.attack @player, 1
    assert_equal 1, @observer.value[1]
    4.times { @game.pass(@game.priority_player) }
    refute_equal :creature_die, @observer.state
  end
  def test_block
    start_game
    prepare_board_to_attack [Cards::DelverofSecrets.new], [Cards::DelverofSecrets.new]
    @game.phase_manager.jump_to :attackers
    @game.attack @player, 0
    @game.pass @player
    @game.pass @opponent
    @game.block @opponent, 0, 0
    assert_equal :block, @observer.state
  end
  def test_assign_damage
    start_game
    prepare_board_to_attack [Cards::DelverofSecrets.new], [Cards::DelverofSecrets.new, Cards::DelverofSecrets.new]
    @game.phase_manager.jump_to :attackers
    # Attack
    @game.attack @player, 0
    @game.pass @player
    @game.pass @opponent
    # Block
    @game.block @opponent, 0, 0
    @game.pass @opponent
    @game.pass @player
    # Damage
    assignment = { 0 => { 1 => 1 } }
    @game.assign_damage @player, assignment
    assert_equal :assign_damage, @observer.state
    assert_equal assignment, @observer.value
  end
  # def test_creature_die
  #   start_game
  #   prepare_board_to_attack [Cards::DelverofSecrets.new], [Cards::DelverofSecrets.new]
  #   @game.phase_manager.jump_to :attackers
  #   # Attack
  #   @game.attack @player, 0
  #   @game.pass @player
  #   @game.pass @opponent
  #   # Block
  #   @game.block @opponent, 0, 0
  #   @game.pass @opponent
  #   @game.pass @player
  #   assert_equal :creature_die, @observer.state
  #   assert_equal({0 => [0], 1 => [0]}, @observer.value)
  # end
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