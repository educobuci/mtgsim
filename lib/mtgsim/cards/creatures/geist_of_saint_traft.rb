module Cards
  class GeistofSaintTraft < Card
    include Creature
    def initialize
      super "Geist of Saint Traft"
      self.power = 2
      self.toughness = 2
      self.cost = { blue: 1, colorless: 1, white: 1 }
    end
  end
end