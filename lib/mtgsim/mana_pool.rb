class ManaPool
  def initialize
    @values = { black: 0, blue: 0, colorless: 0, green: 0, red: 0, white: 0 }
  end
  def to_hash
    @values
  end
  def add(color, amount=1)
    @values[color] += amount
  end
  def eval_cost(card)
    card.cost.each_pair do |key, value|
      if @values[key] < value && key != :colorless
        return false
      end
    end
    total >= card_total(card)
  end
  def card_total(card)
    total = 0
    card.cost.each_value do |value|
      total += value
    end
    return total
  end
  def total
    total = 0
    @values.each_value do |value|
      total += value
    end
    return total
  end
end