module Cards
  class Island < Card
    include Land
    def initialize
      super "Island"
      self.color = :blue
    end
  end
end