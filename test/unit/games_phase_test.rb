require "test_helper"
require "mtgsim"

class GamePhaseTest < MiniTest::Unit::TestCase
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

  def test_priority_pass_until_next_turn
    prepare_game
    player = @game.current_player_index
    opponent = @game.current_player_index == 0 ? 1 : 0
  
    8.times do
      @game.pass(player)
      @game.pass(opponent)
    end
      
    assert_equal :upkeep, @game.current_phase
    assert_equal opponent, @game.current_player_index
  end
  
  def test_game_untap_phase
    prepare_game
    player = @game.current_player_index
    opponent = @game.current_player_index == 0 ? 1 : 0
    
    @game.players(opponent).board << Cards::Island.new
    @game.players(opponent).board << Cards::Island.new
    
    @game.players(opponent).board.each { |c| c.tap_card }
  
    8.times do
      @game.pass(player)
      @game.pass(opponent)
    end
      
    refute @game.current_player.board[0].is_tapped?
    refute @game.current_player.board[1].is_tapped?
  end
  
  def test_player_cant_play_land_when_not_in_first_main_phase
    prepare_game
    
    player = @game.current_player_index
    opponent = @game.current_player_index == 0 ? 1 : 0
    
    @game.current_player.hand = [Cards::Island.new, Cards::Island.new]
    
    @game.pass(player)
    @game.pass(opponent)
    
    refute @game.play_card(player, 0)
  end
  
  def test_player_can_play_land_in_second_main_phase
    prepare_game
    
    player = @game.current_player_index
    opponent = @game.current_player_index == 0 ? 1 : 0
    
    @game.current_player.hand = [Cards::Island.new, Cards::Island.new]
    
    6.times do
      @game.pass(player)
      @game.pass(opponent)
    end
    
    assert @game.play_card(player, 0)
  end
  
  def test_player_can_only_play_creatures_in_main_phases
    prepare_game
    player = @game.current_player_index
    @game.current_player.hand = [Cards::SnapcasterMage.new, Cards::SnapcasterMage.new]
    
    @game.current_player.mana_pool.add(:blue, 4)
    
    @game.phase_manager.jump_to :begin_combat
    refute @game.play_card(player, 0)
    
    @game.phase_manager.jump_to :second_main
    assert @game.play_card(player, 0)
  end
end