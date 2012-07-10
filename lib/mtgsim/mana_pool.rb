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
  def [](index)
    @values[index]
  end
  def pay_cost(card)
    card.cost.each_pair do |key, value|
      if @values[key] < value && key != :colorless
        return false
      end
    end
    if total >= card_total(card)
      card.cost.each_pair do |key, value|
        if key != :colorless
          @values[key] -= value
        end
      end
      paid = 0
      if card.cost[:colorless]
        @values.each_pair do |key, value|
          if paid < card.cost[:colorless] && value > 0
            to_be_paid = [card.cost[:colorless], value].min
            @values[key] -= to_be_paid
            paid += to_be_paid
          end
        end        
      end
      return true
    else
      return false
    end
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