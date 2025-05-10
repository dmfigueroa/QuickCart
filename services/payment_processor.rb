# frozen_string_literal: true

# Simulates payment processing.
class PaymentProcessor
  private attr_reader :order_id, :card

  def initialize(order_id, card)
    @order_id = order_id
    @card = card
  end

  def process_payment
    puts "Processing payment for order #{order_id} with card ending in #{card}..."

    sleep 1 # Simulate network latency
    raise 'Invalid card number.' unless card_number_valid?

    true
  end

  private

  def card_number_valid?
    card.number != 'INVALID_CARD_NUMBER'
  end
end
