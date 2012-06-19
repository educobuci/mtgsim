class Player
  attr_accessor :hand, :deck, :library, :graveyard, :battlefield, :mana_pool
  def initialize
    @hand = []
    @deck = []
    @library = []
    @battlefield = []
    @mana_pool = []
    56.times { @deck << Cards::Island.new }
    4.times { @deck << Cards::Snapcaster.new }
  end
end