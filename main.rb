# frozen_string_literal: true

require_relative 'models/inventory'
require_relative 'models/customer'
require_relative 'order_processor'

puts "\n--- INITIALIZING INVENTORY ---"
inventory = Inventory.new
puts inventory
puts "------------------------------\n"

puts "\n------ ADDING CUSTOMER -------"
customer1 = Customer.new({ name: 'John Doe', email: 'john.doe@example.com', address: '123 Main St, Anytown, USA' })
puts customer1
puts "------------------------------\n\n"

order1 = OrderProcessor.new(inventory, customer1)
order1.add_item(inventory.find_item('ITEM001'), 2)
order1.add_item(inventory.find_item('ITEM003'), 1)

if order1.process_payment('VALID_CARD_NUMBER', '12/25', '123')
  puts 'Order 1 processing complete.'
else
  puts 'Order 1 processing failed.'
end

puts "\nUpdated Inventory: \n#{inventory}"

puts "\n------ ADDING CUSTOMER -------"
customer2 = Customer.new({
                           name: 'Jane Smith',
                           email: 'jane.smith@example.com',
                           address: '456 Oak Ave, Otherville, USA'
                         })
puts customer2
puts "------------------------------\n"

order2 = OrderProcessor.new(inventory, customer2)
order2.add_item(inventory.find_item('ITEM002'), 1) # Mega Gadget
order2.process_payment('INVALID_CARD_NUMBER', '01/24', '456') # This will fail

puts "\nFinal Inventory: \n#{inventory}"
