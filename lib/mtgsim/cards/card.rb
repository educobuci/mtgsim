module Cards
  class Card
    attr_reader :name
    def initialize(name)
      @name = name
      @tapped = false
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