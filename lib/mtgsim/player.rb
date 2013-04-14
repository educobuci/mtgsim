class Player
  attr_accessor :mulligan, :keep, :hand, :deck, :library, :graveyard, :board, :mana_pool,
    :id
  def initialize
    @hand = []
    @deck = []
    @library = []
    @board = []
    @mana_pool = ManaPool.new
    @mulligan = 0
    48.times { @deck << Cards::Island.new }
    4.times { @deck << Cards::SnapcasterMage.new }
    4.times { @deck << Cards::DelverofSecrets.new }
    4.times { @deck << Cards::GeistofSaintTraft.new }
  end
end
