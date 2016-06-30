module Cards
  class MotherofRunes < Card
    include Creature
    def initialize
      super "Mother of Runes", :eternal_masters, 22, [:creature], [:human, :cleric]
      self.power = 1
      self.toughness = 1
      self.cost = { white: 1 }
      self.image = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=413564&type=card"
    end
  end
end
