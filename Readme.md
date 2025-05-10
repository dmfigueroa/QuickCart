This is a coding exercise made by Google Gemini. The goal is to take the provided `OrderProcessor` class and refactor it so that each resulting class adheres more closely to the Single Responsibility Principle.

## The Scenario: "QuickCart Online Orders"

**Background:**
QuickCart is a small, rapidly growing e-commerce startup. When they first launched, they needed a way to process customer orders quickly. A single, all-encompassing `OrderProcessor` class was created to handle everything: adding items to an order, calculating the total cost (including a simple sales tax), validating customer information, processing a (very basic, simulated) credit card payment, "updating" a conceptual inventory count, and generating a plain text order summary.

This initial solution worked well enough for a MVP (Minimum Viable Product) when the business was small, and all orders were straightforward.

**The Challenge & Future Features:**
QuickCart is now looking to expand and improve its services. They have a list of new features and improvements they want to implement:

1.  **Advanced Discount System:** They want to introduce various types of discounts: percentage-based, fixed amount off, buy-one-get-one-free, and discounts applicable only to specific customer segments or products.
2.  **Multiple Payment Gateways:** Instead of just the basic simulated credit card processing, they want to integrate with actual payment gateways (e.g., Stripe, PayPal) and also allow payment with store credit.
3.  **Real-time Inventory Management:** The current "inventory update" is too simplistic. They need a more robust system that can handle stock reservations, backorders, and notify suppliers when stock is low.
4.  **Sophisticated Order Confirmation:** They want to move beyond plain text. Confirmations should be nicely formatted (perhaps HTML emails), include shipping information (once that's implemented), and potentially offer related products.
5.  **Customer Account Integration:** Customer validation needs to be more robust, potentially linking to a customer account system for order history, saved addresses, etc.
6.  **Reporting & Analytics:** Management needs detailed reports on sales, popular products, payment methods used, etc.

The development team has realized that the current `OrderProcessor` class will become a nightmare to maintain and extend if they try to cram all this new functionality into it. It's already becoming difficult to change one part without risking breaking another.

**Your Task:**
Refactor the `OrderProcessor` class below. Your goal is to identify the different responsibilities currently handled by this single class and separate them into new, more focused classes, each adhering to the Single Responsibility Principle.

```ruby
# order_processor.rb

class OrderProcessor
  attr_reader :order_id, :customer_name, :customer_email, :customer_address, :items, :status

  # Simulated global inventory
  @@inventory = {
    "ITEM001" => { name: "Super Widget", price: 19.99, stock: 10 },
    "ITEM002" => { name: "Mega Gadget", price: 29.99, stock: 5 },
    "ITEM003" => { name: "Basic Thingamajig", price: 9.99, stock: 20 }
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
      puts "Error: Cannot add items to an order that is not pending or has failed payment."
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
      puts "Error: Customer name is required."
      return false
    end
    unless @customer_email =~ URI::MailTo::EMAIL_REGEXP
      puts "Error: Invalid customer email format."
      return false
    end
    if @customer_address.nil? || @customer_address.strip.empty?
      puts "Error: Customer address is required."
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

    if card_number == "INVALID_CARD_NUMBER" # Simulate a failed payment
      @status = :payment_failed
      puts "Payment FAILED for order #{@order_id}."
      return false
    else
      @status = :paid
      order_totals = calculate_total
      puts "Payment SUCCEEDED for order #{@order_id}. Amount: $#{'%.2f' % order_totals[:total]}."
      update_inventory
      generate_order_summary
      send_confirmation_email
      return true
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
    "ORD" + Time.now.to_i.to_s + rand(100..999).to_s
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
# puts "Initial Inventory: #{OrderProcessor.class_variable_get(:@@inventory)}"
#
# order1 = OrderProcessor.new("John Doe", "john.doe@example.com", "123 Main St, Anytown, USA")
# order1.add_item("ITEM001", 2)
# order1.add_item("ITEM003", 1)
#
# if order1.process_payment("VALID_CARD_NUMBER", "12/25", "123")
#   puts "Order 1 processing complete."
# else
#   puts "Order 1 processing failed."
# end
#
# puts "\nUpdated Inventory: #{OrderProcessor.class_variable_get(:@@inventory)}"
#
# order2 = OrderProcessor.new("Jane Smith", "jane.smith@example.com", "456 Oak Ave, Otherville, USA")
# order2.add_item("ITEM002", 1) # Mega Gadget
# order2.process_payment("INVALID_CARD_NUMBER", "01/24", "456") # This will fail
#
# puts "\nFinal Inventory: #{OrderProcessor.class_variable_get(:@@inventory)}"
```

Good luck with the refactoring!