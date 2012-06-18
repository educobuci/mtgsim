module Cards
  class Island < Card
    include Land
    def initialize
      super "Island"
      self.mana = :land
    end
  end
end