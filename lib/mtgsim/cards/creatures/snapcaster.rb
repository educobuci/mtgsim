module Cards
  class Snapcaster < Card
    include Creature
    def initialize
      super "Snapcaster Mage"
      self.power = 2
      self.toughness = 1
      self.cost = {blue: 1, colorless: 1}
    end
  end
end