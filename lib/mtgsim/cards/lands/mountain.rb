module Cards
  class Mountain < Card
    include Land
    def initialize
      super "Mountain", :none, 0
      self.color = :red
    end
  end
end