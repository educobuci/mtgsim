module Cards
  class Plains < Card
    include Land
    def initialize
      super "Plains"
      self.color = :white
    end
  end
end