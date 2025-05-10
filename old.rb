require 'uri'

class OrderProcessor
  attr_reader :order_id, :customer_name, :customer_email, :customer_address, :items, :status

  # Simulated global inventory
  @@inventory = {
    'ITEM001' => { name: 'Super Widget', price: 19.99, stock: 10 },
    'ITEM002' => { name: 'Mega Gadget', price: 29.99, stock: 5 },
    'ITEM003' => { name: 'Basic Thingamajig', price: 9.99, stock: 20 }
  }

  def initialize(customer_name, customer_email, customer_address)
    @order_id = generate_order_id
    @customer_name = customer_name
    @customer_email = customer_email
    @customer_address = customer_address
    @items = [] # Each item: { item_code: "ITEM001", quantity: 1, unit_price: 19.99 }
    @status = :pending
    puts "Order #{@order_id} created for #{@customer_name}."
  end

  def add_item(item_code, quantity)
    if @status != :pending && @status != :payment_failed
      puts 'Error: Cannot add items to an order that is not pending or has failed payment.'
      return false
    end

    product_info = @@inventory[item_code]
    if product_info.nil?
      puts "Error: Item code #{item_code} not found."
      return false
    end

    if product_info[:stock] < quantity
      puts "Error: Insufficient stock for #{product_info[:name]}. Available: #{product_info[:stock]}, Requested: #{quantity}."
      return false
    end

    @items << { item_code: item_code, quantity: quantity, unit_price: product_info[:price] }
    puts "#{quantity} of #{product_info[:name]} added to order #{@order_id}."
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
    if @customer_name.nil? || @customer_name.strip.empty?
      puts 'Error: Customer name is required.'
      return false
    end
    unless @customer_email =~ URI::MailTo::EMAIL_REGEXP
      puts 'Error: Invalid customer email format.'
      return false
    end
    if @customer_address.nil? || @customer_address.strip.empty?
      puts 'Error: Customer address is required.'
      return false
    end
    puts "Customer details validated for order #{@order_id}."
    true
  end

  def process_payment(card_number, expiry_date, cvv)
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
    summary += "Customer: #{@customer_name} (#{@customer_email})\n"
    summary += "Address: #{@customer_address}\n"
    summary += "Status: #{@status}\n"
    summary += "Items:\n"
    @items.each do |item|
      product_name = @@inventory[item[:item_code]][:name]
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
    'ORD' + Time.now.to_i.to_s + rand(100..999).to_s
  end

  def update_inventory
    puts "Updating inventory for order #{@order_id}..."
    @items.each do |item|
      if @@inventory[item[:item_code]]
        @@inventory[item[:item_code]][:stock] -= item[:quantity]
        puts "  Stock for #{@@inventory[item[:item_code]][:name]} reduced to #{@@inventory[item[:item_code]][:stock]}."
      end
    end
  end

  def send_confirmation_email
    # Simulate sending an email
    puts "Simulating sending confirmation email to #{@customer_email} for order #{@order_id}."
    # In a real app, this would use an email library and templates.
  end
end

# Example of how the class might be used (for context, not part of the problem code to refactor directly)
#
puts "Initial Inventory: #{OrderProcessor.class_variable_get(:@@inventory)}"

order1 = OrderProcessor.new('John Doe', 'john.doe@example.com', '123 Main St, Anytown, USA')
order1.add_item('ITEM001', 2)
order1.add_item('ITEM003', 1)

if order1.process_payment('VALID_CARD_NUMBER', '12/25', '123')
  puts 'Order 1 processing complete.'
else
  puts 'Order 1 processing failed.'
end

puts "\nUpdated Inventory: #{OrderProcessor.class_variable_get(:@@inventory)}"

order2 = OrderProcessor.new('Jane Smith', 'jane.smith@example.com', '456 Oak Ave, Otherville, USA')
order2.add_item('ITEM002', 1) # Mega Gadget
order2.process_payment('INVALID_CARD_NUMBER', '01/24', '456') # This will fail

puts "\nFinal Inventory: #{OrderProcessor.class_variable_get(:@@inventory)}"
