module Cards
  class SnapcasterMage < Card
    include Creature
    def initialize
      super "Snapcaster Mage", :innistrad, 78
      self.power = 2
      self.toughness = 1
      self.cost = { blue: 1, colorless: 1 }
      self.types = [:human, :wizard]
    end
  end
end