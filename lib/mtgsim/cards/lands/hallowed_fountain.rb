module Cards
  class HallowedFountain < Card
    include Land
    def initialize
      super "Hallowed Fountain", :return_to_ravnica, 241
      self.color = :blue
      self.image = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=253684&type=card"
    end
  end
end