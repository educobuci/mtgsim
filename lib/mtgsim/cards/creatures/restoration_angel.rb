module Cards
  class RestorationAngel < Card
    include Creature
    def initialize
      super "Restoration Angel", :avacyn_restored, 32, [:creature], [:angel]
      self.power = 3
      self.toughness = 4
      self.cost = { colorless: 3, white: 1 }
      self.image = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=240096&type=card"
    end
  end
end