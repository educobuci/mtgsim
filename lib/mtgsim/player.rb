class Player
  attr_accessor :hand, :deck, :library, :graveyard, :battlefield, :mana_pool,
    :id
  def initialize
    @hand = []
    @deck = []
    @library = []
    @battlefield = []
    @mana_pool = ManaPool.new
    48.times { @deck << Cards::Island.new }
    4.times { @deck << Cards::SnapcasterMage.new }
    4.times { @deck << Cards::DelverofSecrets.new }
    4.times { @deck << Cards::GeistofSaintTraft.new }
  end
end
