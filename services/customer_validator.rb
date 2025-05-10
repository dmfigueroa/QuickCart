# frozen_string_literal: true

# Validates customer details
class CustomerValidator
  private attr_reader :customer

  def initialize(customer)
    @customer = customer
  end

  def validate
    validate_name
    validate_email
    validate_address

    true
  rescue StandardError => e
    puts "Customer validation failed: #{e.message}"
    false
  end

  private

  def validate_name
    raise 'Name is required' unless customer.name && !customer.name.strip.empty?
  end

  def validate_email
    raise 'Email is required' unless customer.email && !customer.email.strip.empty?
    raise 'Invalid email format' unless customer.email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def validate_address
    raise 'Address is required' unless customer.address && !customer.address.strip.empty?
  end
end
