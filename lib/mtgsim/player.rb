class Player
  attr_accessor :hand, :deck, :library, :graveyard, :battlefield, :mana_pool
  def initialize
    @hand = []
    @deck = []
    @library = []
    @battlefield = []
    @mana_pool = { black:0, blue: 0, green: 0, red: 0, white: 0 }
    56.times { @deck << Cards::Island.new }
    4.times { @deck << Cards::Snapcaster.new }
  end
end