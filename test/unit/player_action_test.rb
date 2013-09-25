require "test_helper"
require "mtgsim"

class PlayerActionTest < MiniTest::Unit::TestCase
  def setup
    @game = Game.new [Player.new, Player.new]
  end
  
  def prepare_game
    @game.roll_dices
    @game.start_player(@game.die_winner, @game.die_winner)
    @game.draw_hands
    @game.keep(0)
    @game.keep(1)
    @game.start()
  end
  
  def test_card_play_before_game_start
    @game.roll_dices
    @game.start_player(@game.die_winner, @game.die_winner)
    @game.draw_hands
    
    refute @game.play_card(@game.die_winner, 0)
  end
  
  def test_play_land_card_in_main_phase
    prepare_game
    @game.current_player.hand[0] = Cards::Island.new
    player = @game.current_player_index
    
    assert @game.play_card(player, 0)
    
    assert_equal 6, @game.current_player.hand.size
    assert_equal 1, @game.current_player.board.size
    refute @game.current_player.hand.include?(@game.current_player.board.first)
  end
  
  def test_only_current_gamer_can_play_cards
    prepare_game
    other_player_index = @game.current_player_index == 0 ? 1 : 0
    other_player = @game.players(other_player_index)
    other_player.hand[0] = Cards::Island.new
    
    refute @game.play_card(other_player_index, 0)
    
    assert_equal 7, other_player.hand.size
    assert_equal 0, other_player.board.size
  end
  
  def test_tap_land_to_add_a_mana_to_pool
    prepare_game
    @game.current_player.hand[0] = Cards::Island.new
    player = @game.current_player_index
    
    assert @game.play_card(player, 0)
    
    @game.tap_card(player, 0)
    assert_equal 1, @game.current_player.mana_pool[:blue]
  end
  
  def test_cant_tap_a_tapped_card
    prepare_game
    @game.current_player.hand[0] = Cards::Island.new
    player = @game.current_player_index
    
    assert @game.play_card(player, 0)
    
    @game.tap_card(player, 0)
    @game.tap_card(player, 0)
    
    assert_equal 1, @game.current_player.mana_pool[:blue]
  end
  
  def test_cast_cancelation
    prepare_game
    @game.current_player.hand[0] = Cards::Island.new
    player = @game.current_player_index
    
    assert @game.play_card(player, 0)
    
    @game.tap_card(player, 0)
    @game.cancel_cast(player)
    
    assert_equal 0, @game.current_player.mana_pool[:blue]
    refute @game.current_player.hand[0].is_tapped?
  end
  
  def test_cast_cancelation_only_before_the_cast
    prepare_game
    2.times { @game.current_player.board << Cards::Island.new }
    @game.current_player.hand = [Cards::DelverofSecrets.new]    
    
    player = @game.current_player_index
    
    @game.tap_card(player, 0)
    @game.tap_card(player, 1)
    
    @game.play_card(player, 0)
    
    @game.cancel_cast(player)
    assert_equal 1, @game.current_player.mana_pool[:blue]
  end
  
  def test_mana_cost
    prepare_game
    @game.current_player.hand = [Cards::SnapcasterMage.new]
    refute @game.play_card(@game.current_player_index, 0)
    
    2.times { @game.current_player.board << Cards::Island.new }
    
    @game.tap_card @game.current_player_index, 0
    @game.tap_card @game.current_player_index, 1
    
    assert @game.play_card(@game.current_player_index, 0)
  end
  
  def test_land_fall_rule
    prepare_game
    @game.current_player.hand = [Cards::Island.new, Cards::Island.new]
    assert @game.play_card(@game.current_player_index, 0)
    refute @game.play_card(@game.current_player_index, 0)
  end
  
  def test_priority_pass
    prepare_game
    player = @game.current_player_index
    opponent = @game.current_player_index == 0 ? 1 : 0
    @game.pass(player)
    assert_equal opponent, @game.priority_player
  end
  
  def test_priority_pass_changes_to_next_phase
    prepare_game
    player = @game.current_player_index
    opponent = @game.current_player_index == 0 ? 1 : 0
    
    @game.pass(player)
    @game.pass(opponent)
        
    assert_equal :begin_combat, @game.current_phase
  end
  
  def test_creature_etb_sickness
    prepare_game
    
    @game.current_player.hand = [Cards::DelverofSecrets.new]
    @game.current_player.board << Cards::Island.new

    @game.tap_card @game.current_player_index, 0
    @game.play_card(@game.current_player_index, 0)
    
    assert @game.current_player.board[1].sickness    

    @game.phase_manager.jump_to :end
    @game.pass(0)
    @game.pass(1)
    @game.phase_manager.jump_to :end
    @game.pass(1)
    @game.pass(0)
    
    refute @game.current_player.board[1].sickness
  end
  
end