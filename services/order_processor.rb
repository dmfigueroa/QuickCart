# frozen_string_literal: true

require 'uri'
require_relative '../models/cart'

# Processes customer orders, manages items, calculates totals, and handles payment.
class OrderProcessor
  attr_reader :customer, :status, :inventory

  def initialize(inventory, customer)
    @customer = customer
    @cart = Cart.new
    @status = :pending
    @inventory = inventory

    puts "Order #{order_id} created for #{@customer.name}."
  end

  def add_item(product, quantity)
    validate_can_add_items(product, quantity)

    @cart.add_item(product, quantity)
    puts "#{quantity} of #{product.name} added to order #{order_id}."
  rescue StandardError => e
    puts "Error: #{e.message}"
  end

  def calculate_total
    @cart.calculate_total
  end

  def validate_customer_details
    # Basic validation
    if @customer.name.nil? || @customer.name.strip.empty?
      puts 'Error: Customer name is required.'
      return false
    end
    unless @customer.email =~ URI::MailTo::EMAIL_REGEXP
      puts 'Error: Invalid customer email format.'
      return false
    end
    if @customer.address.nil? || @customer.address.strip.empty?
      puts 'Error: Customer address is required.'
      return false
    end
    puts "Customer details validated for order #{order_id}."
    true
  end

  def process_payment(card)
    unless validate_customer_details
      @status = :validation_failed
      puts "Payment processing aborted due to validation errors for order #{order_id}."
      return false
    end

    if @cart.empty?
      puts "Error: Cannot process payment for an empty order (#{order_id})."
      return false
    end

    # Simulate credit card payment processing
    puts "Processing payment for order #{order_id} with card ending in #{card}..."
    sleep 1 # Simulate network latency

    if card.number == 'INVALID_CARD_NUMBER' # Simulate a failed payment
      @status = :payment_failed
      puts "Payment FAILED for order #{order_id}."
      false
    else
      @status = :paid
      order_totals = calculate_total
      puts "Payment SUCCEEDED for order #{order_id}. Amount: $#{'%.2f' % order_totals[:total]}."
      update_inventory
      generate_order_summary
      send_confirmation_email
      true
    end
  end

  def generate_order_summary
    return "Order summary cannot be generated for status: #{@status}" unless @status == :paid

    summary = "Order Summary for Order ID: #{order_id}\n"
    summary += "Customer: #{@customer.name} (#{@customer.email})\n"
    summary += "Address: #{@customer.address}\n"
    summary += "Status: #{@status}\n"
    summary += "Items:\n"
    summary += "#{@cart}\n"
    summary += "Subtotal: $#{'%.2f' % @cart.subtotal}\n"
    summary += "Tax (7%): $#{'%.2f' % @cart.tax}\n"
    summary += "Total: $#{'%.2f' % @cart.total}\n"
    summary += "Thank you for your order!\n"

    puts "\n--- ORDER SUMMARY (#{order_id}) ---"
    puts summary
    puts "---------------------------\n"
    summary
  end

  private

  def order_id
    @order_id ||= generate_order_id
  end

  def generate_order_id
    "ORD-#{Time.now.to_i}-#{rand(100..999)}"
  end

  def update_inventory
    puts "Updating inventory for order #{order_id}..."
    @cart.items.each do |item|
      if @inventory.items[item.item.id]
        @inventory.items[item.item.id].stock -= item.quantity
        puts "  Stock for #{@inventory.items[item.item.id].name} reduced to #{@inventory.items[item.item.id].stock}."
      end
    end
  end

  def send_confirmation_email
    # Simulate sending an email
    puts "Simulating sending confirmation email to #{@customer.email} for order #{order_id}."
    # In a real app, this would use an email library and templates.
  end

  def can_modify_order?
    @status == :pending || @status == :payment_failed
  end

  def validate_can_add_items(product, quantity)
    raise 'Cannot add items to an order that is not pending or has failed payment.' unless can_modify_order?

    raise 'Item not found.' if product.nil?

    unless product.in_stock?(quantity)
      raise "Insufficient stock for #{product.name}. Available: #{product.stock}, Requested: #{quantity}."
    end

    true
  end
end
