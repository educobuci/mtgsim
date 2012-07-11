module Cards
  class Swamp < Card
    include Land
    def initialize
      super "Swamp", :none, 0
      self.color = :black
    end
  end
end