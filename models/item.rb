# frozen_string_literal: true

# Represents an item in the inventory.
class Item
  attr_accessor :id, :name, :stock

  def initialize(id, args)
    @id = id
    @name = args[:name]
    @price = args[:price]
    @stock = args[:stock]
  end

  def price(quantity = 1)
    @price * quantity
  end

  def in_stock?(quantity = 1)
    stock >= quantity
  end

  def to_s
    "Item -> #{name} (ID: #{id}) has stock of #{stock} for $#{price} each"
  end
end
