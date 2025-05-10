# frozen_string_literal: true

require 'uri'
require_relative '../models/cart'
require_relative 'customer_validator'
require_relative 'payment_processor'
require_relative 'order_summary_generator'

# Processes customer orders, manages items, calculates totals, and handles payment.
class OrderProcessor
  attr_reader :id, :customer, :status, :inventory

  def initialize(inventory, customer)
    @customer = customer
    @cart = Cart.new
    @status = :pending
    @inventory = inventory
    @id = generate_order_id

    puts "Order #{id} created for #{@customer.name}."
  end

  def add_item(product, quantity)
    validate_can_add_items(product, quantity)

    @cart.add_item(product, quantity)
    puts "#{quantity} of #{product.name} added to order #{id}."
  rescue StandardError => e
    puts "Error: #{e.message}"
  end

  def complete_order(card)
    validate_order(card)

    @status = :paid
    puts "Payment SUCCEEDED for order #{id}. Amount: $#{format('%.2f', @cart.total)}."
    process_order
    generate_order_summary
    send_confirmation_email

    true
  rescue StandardError
    puts "Payment failed for order #{id}"
    false
  end

  def generate_order_summary
    return "Order summary cannot be generated for status: #{status}" unless paid?

    OrderSummaryGenerator.new.generate(self, customer, @cart)
  end

  def paid?
    @status == :paid
  end

  private

  def generate_order_id
    "ORD-#{Time.now.to_i}-#{rand(100..999)}"
  end

  def process_order
    @inventory.process_order(id, @cart)
  end

  def send_confirmation_email
    # Simulate sending an email
    puts "Simulating sending confirmation email to #{@customer.email} for order #{id}."
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

  def validate_order(card)
    validate_customer
    validate_cart
    validate_payment(card)
  end

  def validate_customer
    return if valid_customer?

    @status = :validation_failed
    raise StandardError, "Aborted due to validation errors for order #{id}."
  end

  def valid_customer?
    is_valid = CustomerValidator.new(customer).validate
    puts "Customer details validated for order #{id}."

    is_valid
  end

  def validate_cart
    return unless @cart.empty?

    raise "Cannot process payment for an empty order (#{id})."
  end

  def validate_payment(card)
    PaymentProcessor.new(id, card).process_payment
  rescue StandardError => e
    @status = :payment_failed
    raise e.message
  end
end
