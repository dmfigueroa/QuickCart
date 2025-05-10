# frozen_string_literal: true

# Represents an item in the cart.
class CartItem
  attr_reader :item, :quantity

  def initialize(item, quantity)
    @item = item
    @quantity = quantity
  end

  def price
    item.price(quantity)
  end

  def summary
    "  - #{item.name} (Code: #{item.id}) x #{quantity} @ $#{item.price} each"
  end
end
