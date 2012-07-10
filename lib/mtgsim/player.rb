class Player
  attr_accessor :hand, :deck, :library, :graveyard, :battlefield, :mana_pool,
    :id
  def initialize
    @hand = []
    @deck = []
    @library = []
    @battlefield = []
    @mana_pool = ManaPool.new
    56.times { @deck << Cards::Island.new }
    4.times { @deck << Cards::Snapcaster.new }
  end
end
