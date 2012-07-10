module Cards
  class Mountain < Card
    include Land
    def initialize
      super "Mountain"
      self.color = :red
    end
  end
end