class Player
  attr_accessor :hand, :deck, :library, :graveyard
  def initialize
    @hand = []
    @deck = []
    @library = []
    @battlefield = []
    56.times { @deck << Cards::Island.new }
    4.times { @deck << Cards::Snapcaster.new }
  end
end