module Cards
  class Forest < Card
    include Land
    def initialize
      super "Forest"
      self.color = :green
    end
  end
end