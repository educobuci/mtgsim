module Cards
  class Island < Card
    include Land
    def initialize
      super "Island", :none, 0, [:land], [:island]
      self.color = :blue
      self.image = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=249723&type=card"
    end
  end
end