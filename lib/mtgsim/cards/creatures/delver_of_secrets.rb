module Cards
  class DelverofSecrets < Card
    include Creature
    def initialize
      super "Delver of Secrets", :innistrad, 51
      self.power = 1
      self.toughness = 1
      self.cost = { blue: 1 }
      self.types = [:human, :wizard]
      self.image = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=226749&type=card"
    end
  end
end