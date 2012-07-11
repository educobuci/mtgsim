module Cards
  class Plains < Card
    include Land
    def initialize
      super "Plains", :none, 0
      self.color = :white
    end
  end
end