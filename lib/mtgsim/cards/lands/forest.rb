module Cards
  class Forest < Card
    include Land
    def initialize
      super "Forest", :none, 0
      self.color = :green
    end
  end
end