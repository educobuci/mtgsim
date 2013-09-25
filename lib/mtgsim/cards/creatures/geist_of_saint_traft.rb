module Cards
  class GeistofSaintTraft < Card
    include Creature
    def initialize
      super "Geist of Saint Traft", :innistrad, 213, [:creature], [:spirit, :cleric]
      self.power = 2
      self.toughness = 2
      self.cost = { blue: 1, colorless: 1, white: 1 }
      self.image = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=247236&type=card"
    end
  end
end