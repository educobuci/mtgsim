require "test_helper"
require "mtgsim"

class CombatTest < Minitest::Test
  def setup
    @game = Game.new [Player.new, Player.new]
    prepare_game
    @player = @game.current_player_index
    @opponent = @game.current_player_index == 0 ? 1 : 0
  end
  
  def prepare_game
    @game.roll_dices
    @game.start_player(@game.die_winner, @game.die_winner)
    @game.draw_hands
    @game.keep(0)
    @game.keep(1)
    @game.start()
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
  
  def test_simple_attack_and_damage
    creature = Cards::DelverofSecrets.new
    @game.players(@player).board.push(creature)
    
    @game.phase_manager.jump_to :attackers
    
    # Declare Delver as attacker
    @game.attack(@game.current_player_index, 0)
    @game.pass(@game.current_player_index)
    @game.pass(@game.opponent_index)
    
    # No blockers are declared
    @game.pass(@game.opponent_index)
    @game.pass(@game.current_player_index)
    
    # Damage Phase
    assert_equal 19, @game.players(@opponent).life
    assert @game.players(@player).board[0].is_tapped?
  end
  
  def x_test_simple_block 
    prepare_board_to_attack [Cards::DelverofSecrets.new, Cards::DelverofSecrets.new], [Cards::DelverofSecrets.new]
  
    @game.phase_manager.jump_to :attackers
    
    # Declare Delver as attacker
    @game.attack(@player, 0)
    @game.attack(@player, 1)
    @game.pass(@player)
    @game.pass(@game.opponent_index)
    
    # Declare Delver as blocker
    @game.block(@opponent, 0, 0)
    @game.pass(@opponent)
    @game.pass(@player)
    
    # Damage Phase
    assert_equal 19, @game.players(@opponent).life
  end
  
  def test_creature_damage
    prepare_board_to_attack [Cards::GeistofSaintTraft.new, Cards::GeistofSaintTraft.new],
      [Cards::DelverofSecrets.new,Cards::DelverofSecrets.new,Cards::DelverofSecrets.new]
  
    @game.phase_manager.jump_to :attackers
    
    @game.attack(@player, 0)
    @game.attack(@player, 1)
    @game.pass(@player)
    @game.pass(@game.opponent_index)
    
    # Double block first
    @game.block(@opponent, 0, 0)
    @game.block(@opponent, 0, 1)
    
    # Chump the other one
    @game.block(@opponent, 1, 2)
    
    @game.pass(@opponent)
    @game.pass(@player)
    
    assert_equal 2, @attackers[0].damage
    assert_equal 1, @attackers[1].damage
    
    assert_equal 1, @blockers[0].damage
    assert_equal 1, @blockers[1].damage
    assert_equal 2, @blockers[2].damage
  end
end