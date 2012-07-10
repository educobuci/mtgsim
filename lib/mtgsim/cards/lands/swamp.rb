module Cards
  class Swamp < Card
    include Land
    def initialize
      super "Swamp"
      self.color = :black
    end
  end
end