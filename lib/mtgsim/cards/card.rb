module Cards
  class Card
    attr_reader :name, :set, :id
    attr_accessor :image
    
    def initialize(name, set, id)
      @name = name
      @tapped = false
      @set = set
      @id = id
    end
    def tap_card
      @tapped = true
    end
    def untap_card
      @tapped = false
    end
    def is_tapped?
      @tapped
    end
  end
end