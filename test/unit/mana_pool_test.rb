require "test_helper"
require "mtgsim"

class ManaPoolTest < MiniTest::Unit::TestCase
  def setup
    @pool = ManaPool.new
  end
  def test_default_values
    assert_equal({ black: 0, blue: 0, colorless: 0, green: 0, red: 0, white: 0 }, @pool.to_hash)
  end
  def test_add
    @pool.add(:blue, 1)
    assert_equal 1, @pool.to_hash[:blue]
    @pool.add(:blue, 1)
    assert_equal 2, @pool.to_hash[:blue]
  end
  def test_simple_cost_eval
    card = Cards::DelverofSecrets.new
    refute @pool.eval_cost(card)
    @pool.add :blue
    assert @pool.eval_cost(card)
  end
  def test_colorless_cost_eval
    card = Cards::Snapcaster.new
    @pool.add :blue, 2
    assert @pool.eval_cost(card)
  end
  def test_multcolor_cost_eval
    card = Cards::GeistofSaintTraft.new
    @pool.add :blue, 2
    refute @pool.eval_cost(card)
    
    @pool.add :white
    assert @pool.eval_cost(card)
  end
end