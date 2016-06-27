require "securerandom"
module Cards
  class Card
    attr_reader :name, :set, :id, :types, :subtypes, :game_id
    attr_accessor :image
    
    def initialize(name, set, id, types, subtypes)
      @name = name
      @tapped = false
      @set = set
      @id = id
      @types = types
      @subtypes = subtypes
      @game_id = SecureRandom.uuid
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