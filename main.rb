# frozen_string_literal: true

require_relative 'models/inventory'
require_relative 'models/customer'
require_relative 'models/card'
require_relative 'services/order_processor'

puts "\n--- INITIALIZING INVENTORY ---"
inventory = Inventory.new
puts inventory
puts "------------------------------\n"

customer1 = Customer.new name: 'John Doe', email: 'john.doe@example.com', address: '123 Main St, Anytown, USA'
puts customer1

order1 = OrderProcessor.new inventory, customer1
order1.add_item inventory.find_item('ITEM001'), 2
order1.add_item inventory.find_item('ITEM003'), 1

card1 = Card.new '1234567890123456', '12/25', '123'
if order1.complete_order card1
  puts 'Order 1 processing complete.'
else
  puts 'Order 1 processing failed.'
end

puts "\nUpdated Inventory: \n#{inventory}\n\n"

customer2 = Customer.new name: 'Jane Smith', email: 'jane.smith@example.com', address: '456 Oak Ave, Otherville, USA'

order2 = OrderProcessor.new inventory, customer2
order2.add_item inventory.find_item('ITEM002'), 1 # Mega Gadget
card2 = Card.new 'INVALID_CARD_NUMBER', '01/24', '456'
order2.complete_order card2 # This will fail

puts "\nFinal Inventory: \n#{inventory}\n\n"
