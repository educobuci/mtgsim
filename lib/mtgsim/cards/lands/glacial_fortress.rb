module Cards
  class GlacialFortress < Card
    include Land
    def initialize
      super "Glacial Fortress", :m13, 225
      self.color = :blue
      self.image = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=249722&type=card"
    end
  end
end