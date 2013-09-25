module Cards
  class Plains < Card
    include Land
    def initialize
      super "Plains", :none, 0, [:land],  [:plains]
      self.color = :white
      self.image = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=289310&type=card"
    end
  end
end