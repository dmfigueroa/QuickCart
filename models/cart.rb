# frozen_string_literal: true

require_relative 'cart_item'

# Represents a shopping cart that holds items.
class Cart
  attr_reader :items

  def initialize
    @items = []
  end

  def add_item(item, quantity)
    @items << CartItem.new(item, quantity)
  end

  def empty?
    @items.empty?
  end

  def total
    subtotal + tax
  end

  def summary
    result = "Items:\n"
    result += @items.map(&:summary).join("\n")
    result += "\n"
    result += "Subtotal: $#{format('%.2f', subtotal)}\n"
    result += "Tax (7%): $#{format('%.2f', tax)}\n"
    result += "Total: $#{format('%.2f', total)}\n"
    result
  end

  private

  def subtotal
    @items.sum(&:price)
  end

  def tax
    subtotal * 0.07
  end
end
