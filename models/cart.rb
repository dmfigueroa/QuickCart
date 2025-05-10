# frozen_string_literal: true

# Represents a shopping cart that holds items.
class Cart
  attr_reader :items

  def initialize
    @items = []
  end

  def add_item(item, quantity)
    @items << { item: item, quantity: quantity }
  end

  def calculate_total
    {
      subtotal: subtotal,
      tax: tax,
      total: total
    }
  end

  def summary
    "Cart -> #{@items.map { |item| "#{item[:item].name} x #{item[:quantity]}" }.join(', ')}"
  end

  def empty?
    @items.empty?
  end

  private

  def subtotal
    @items.sum { |item| item[:item].price * item[:quantity] }
  end

  def tax
    subtotal * 0.07
  end

  def total
    subtotal + tax
  end
end
