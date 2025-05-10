# frozen_string_literal: true

# Generates a summary of an order.
class OrderSummaryGenerator
  def generate(order_id, status, customer, cart)
    summary = "Order Summary for Order ID: #{order_id}\n"
    summary += customer.summary
    summary += "Status: #{status}\n"
    summary += cart.summary
    summary += "Thank you for your order!\n"

    puts "\n--- ORDER SUMMARY (#{order_id}) ---"
    puts summary
    puts "---------------------------\n"
    summary
  end
end
