# frozen_string_literal: true

require 'uri'
require_relative '../models/cart'
require_relative '../models/order'
require_relative 'customer_validator'
require_relative 'payment_processor'

# Processes customer orders, manages items, calculates totals, and handles payment.
class OrderProcessor
  attr_reader :order, :inventory

  def initialize(inventory, customer)
    @order = Order.new(customer)
    @inventory = inventory
  end

  def add_item(product, quantity)
    validate_can_add_items(product, quantity)

    order.add_item(product, quantity)
  rescue StandardError => e
    puts "Error: #{e.message}"
  end

  def complete_order(card)
    validate_order(card)

    process_order
    update_inventory
    send_confirmation_email

    true
  rescue StandardError
    puts "Payment failed for order #{order.id}"
    false
  end

  private

  def process_order
    order.paid!
    puts "Payment SUCCEEDED for order #{order.id}. Amount: $#{format('%.2f', order.total)}."
    order.print_summary
  end

  def update_inventory
    @inventory.process_order(order.id, order.cart)
  end

  def send_confirmation_email
    # Simulate sending an email
    puts "Simulating sending confirmation email to #{order.customer.email} for order #{order.id}."
    # In a real app, this would use an email library and templates.
  end

  def validate_can_add_items(product, quantity)
    raise 'Cannot add items to an order that is not pending or has failed payment.' unless order.can_modify?

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

    order.validation_failed!
    raise StandardError, "Aborted due to validation errors for order #{order.id}."
  end

  def valid_customer?
    is_valid = CustomerValidator.new(order.customer).validate
    puts "Customer details validated for order #{order.id}."

    is_valid
  end

  def validate_cart
    return unless order.empty?

    raise "Cannot process payment for an empty order (#{order.id})."
  end

  def validate_payment(card)
    PaymentProcessor.new(order.id, card).process_payment
  rescue StandardError => e
    order.payment_failed!
    raise e.message
  end
end
