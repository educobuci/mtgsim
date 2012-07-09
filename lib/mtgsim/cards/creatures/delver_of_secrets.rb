module Cards
  class DelverofSecrets < Card
    include Creature
    def initialize
      super "Delver of Secrets"
      self.power = 2
      self.toughness = 1
      self.cost = { blue: 1 }
    end
  end
end