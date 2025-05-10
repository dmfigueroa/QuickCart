# frozen_string_literal: true

# Represents an order.
class Order
  attr_reader :id, :status, :customer, :cart

  def initialize(customer)
    @customer = customer
    @cart = Cart.new
    @id = generate_order_id
    @status = :pending

    puts "Order #{id} created for #{customer.name}."
  end

  def add_item(product, quantity)
    @cart.add_item(product, quantity)

    puts "#{quantity} of #{product.name} added to order #{id}."
  end

  def paid?
    @status == :paid
  end

  def paid!
    @status = :paid
  end

  def can_modify?
    @status == :pending || @status == :payment_failed
  end

  def validation_failed!
    @status = :validation_failed
  end

  def empty?
    @cart.empty?
  end

  def total
    @cart.total
  end

  def print_summary
    return "Order summary cannot be generated for status: #{status}" unless paid?

    result = "Order Summary for Order ID: #{id}\n"
    result += customer.summary
    result += "Status: #{status}\n"
    result += cart.summary
    result += "Thank you for your order!\n"

    puts "\n--- ORDER SUMMARY (#{id}) ---"
    puts result
    puts "---------------------------\n"
  end

  private

  def generate_order_id
    "ORD-#{Time.now.to_i}-#{rand(100..999)}"
  end
end
