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
    summary = "Items:\n"
    summary += @items.map(&:summary).join("\n")
    summary += "\n"
    summary += "Subtotal: $#{format('%.2f', subtotal)}\n"
    summary += "Tax (7%): $#{format('%.2f', tax)}\n"
    summary += "Total: $#{format('%.2f', total)}\n"
    summary
  end

  private

  def subtotal
    @items.sum(&:price)
  end

  def tax
    subtotal * 0.07
  end
end
