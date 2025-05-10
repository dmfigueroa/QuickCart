# frozen_string_literal: true

# Generates a summary of an order.
class OrderSummaryGenerator
  def generate(order, customer, cart)
    summary = "Order Summary for Order ID: #{order.id}\n"
    summary += customer.summary
    summary += "Status: #{order.status}\n"
    summary += cart.summary
    summary += "Thank you for your order!\n"

    puts "\n--- ORDER SUMMARY (#{order.id}) ---"
    puts summary
    puts "---------------------------\n"
    summary
  end
end
