module Cards
  class SnapcasterMage < Card
    include Creature
    def initialize
      super "Snapcaster Mage", :innistrad, 78, [:creature], [:human, :wizard]
      self.power = 2
      self.toughness = 1
      self.cost = { blue: 1, colorless: 1 }
      self.image = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=227676&type=card"
    end
  end
end