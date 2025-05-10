# frozen_string_literal: true

# Represents a customer with a name, email, and address.
class Customer
  attr_accessor :name, :email, :address

  def initialize(args)
    @name = args[:name]
    @email = args[:email]
    @address = args[:address]
  end

  def summary
    result = "Customer: #{name} (#{email})\n"
    result += "Address: #{address}\n"
    result
  end

  def to_s
    "Customer -> #{name} (Email: #{email}, Address: #{address})"
  end
end
