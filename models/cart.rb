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

  def subtotal
    @items.sum(&:price)
  end

  def tax
    subtotal * 0.07
  end

  def total
    subtotal + tax
  end

  def to_s
    "  - #{@items.map(&:to_s).join(', ')}"
  end
end
