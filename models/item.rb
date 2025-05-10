# frozen_string_literal: true

# Represents an item in the inventory.
class Item
  attr_accessor :id, :name, :price, :stock

  def initialize(id, args)
    @id = id
    @name = args[:name]
    @price = args[:price]
    @stock = args[:stock]
  end

  def to_s
    "Item -> #{name} (ID: #{id}) has stock of #{stock} for $#{price} each"
  end
end
