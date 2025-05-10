# frozen_string_literal: true

require_relative 'item'

# Represents the collection of items available in the system.
class Inventory
  attr_reader :items

  def initialize
    @items = {
      'ITEM001' => Item.new('ITEM001', { name: 'Super Widget', price: 19.99, stock: 10 }),
      'ITEM002' => Item.new('ITEM002', { name: 'Mega Gadget', price: 29.99, stock: 5 }),
      'ITEM003' => Item.new('ITEM003', { name: 'Basic Thingamajig', price: 9.99, stock: 20 })
    }
  end

  def find_item(item_code)
    items[item_code]
  end

  def process_order(order_id, cart)
    puts "Updating inventory for order #{order_id}..."

    cart.items.each(&method(:update_item_stock))
  end

  def to_s
    items.map { |id, item_object| "  #{id}: #{item_object}" }.join("\n")
  end

  private

  def update_item_stock(cart_item)
    item = items[cart_item.id]
    item.stock -= cart_item.quantity
    puts "  Stock for #{item.name} reduced to #{item.stock}."
  end
end
