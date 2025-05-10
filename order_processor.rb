# frozen_string_literal: true

require_relative './models/inventory'
require 'uri'

# Processes customer orders, manages items, calculates totals, and handles payment.
class OrderProcessor
  attr_reader :order_id, :customer, :items, :status, :inventory

  def initialize(inventory, customer)
    @order_id = generate_order_id
    @customer = customer
    @items = [] # Each item: { item_code: "ITEM001", quantity: 1, unit_price: 19.99 }
    @status = :pending
    @inventory = inventory
    puts "Order #{@order_id} created for #{@customer_name}."
  end

  def add_item(item_code, quantity)
    if @status != :pending && @status != :payment_failed
      puts 'Error: Cannot add items to an order that is not pending or has failed payment.'
      return false
    end

    product_info = @inventory.items[item_code]
    if product_info.nil?
      puts "Error: Item code #{item_code} not found."
      return false
    end

    if product_info.stock < quantity
      puts "Error: Insufficient stock for #{product_info.name}. Available: #{product_info.stock}, Requested: #{quantity}."
      return false
    end

    @items << { item_code: item_code, quantity: quantity, unit_price: product_info.price }
    puts "#{quantity} of #{product_info.name} added to order #{@order_id}."
    true
  end

  def calculate_total
    subtotal = @items.sum { |item| item[:unit_price] * item[:quantity] }
    tax = subtotal * 0.07 # 7% sales tax
    total = subtotal + tax
    { subtotal: subtotal, tax: tax, total: total }
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
    puts "Customer details validated for order #{@order_id}."
    true
  end

  def process_payment(card_number, _expiry_date, _cvv)
    unless validate_customer_details
      @status = :validation_failed
      puts "Payment processing aborted due to validation errors for order #{@order_id}."
      return false
    end

    if @items.empty?
      puts "Error: Cannot process payment for an empty order (#{@order_id})."
      return false
    end

    # Simulate credit card payment processing
    puts "Processing payment for order #{@order_id} with card ending in #{card_number[-4..]}..."
    sleep 1 # Simulate network latency

    if card_number == 'INVALID_CARD_NUMBER' # Simulate a failed payment
      @status = :payment_failed
      puts "Payment FAILED for order #{@order_id}."
      false
    else
      @status = :paid
      order_totals = calculate_total
      puts "Payment SUCCEEDED for order #{@order_id}. Amount: $#{'%.2f' % order_totals[:total]}."
      update_inventory
      generate_order_summary
      send_confirmation_email
      true
    end
  end

  def generate_order_summary
    return "Order summary cannot be generated for status: #{@status}" unless @status == :paid

    summary = "Order Summary for Order ID: #{@order_id}\n"
    summary += "Customer: #{@customer.name} (#{@customer.email})\n"
    summary += "Address: #{@customer.address}\n"
    summary += "Status: #{@status}\n"
    summary += "Items:\n"
    @items.each do |item|
      product_name = @inventory.items[item[:item_code]].name
      summary += "  - #{product_name} (Code: #{item[:item_code]}) x #{item[:quantity]} @ $#{'%.2f' % item[:unit_price]} each\n"
    end
    totals = calculate_total
    summary += "Subtotal: $#{'%.2f' % totals[:subtotal]}\n"
    summary += "Tax (7%): $#{'%.2f' % totals[:tax]}\n"
    summary += "Total: $#{'%.2f' % totals[:total]}\n"
    summary += "Thank you for your order!\n"

    puts "\n--- ORDER SUMMARY (#{@order_id}) ---"
    puts summary
    puts "---------------------------\n"
    summary
  end

  private

  def generate_order_id
    "ORD#{Time.now.to_i}#{rand(100..999)}"
  end

  def update_inventory
    puts "Updating inventory for order #{@order_id}..."
    @items.each do |item|
      if @inventory.items[item[:item_code]]
        @inventory.items[item[:item_code]].stock -= item[:quantity]
        puts "  Stock for #{@inventory.items[item[:item_code]].name} reduced to #{@inventory.items[item[:item_code]].stock}."
      end
    end
  end

  def send_confirmation_email
    # Simulate sending an email
    puts "Simulating sending confirmation email to #{@customer_email} for order #{@order_id}."
    # In a real app, this would use an email library and templates.
  end
end
