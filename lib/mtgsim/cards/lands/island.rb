module Cards
  class Island < Card
    include Land
    def initialize
      super "Island", :none, 0
      self.color = :blue
    end
  end
end