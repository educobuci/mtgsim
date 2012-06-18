module Cards
  class Snapcaster < Card
    include Creature
    def initialize
      super "Snapcaster"
      self.power = 2
      self.toughness = 1
      self.cost = [any: 1, island: 1]
    end
  end
end