# frozen_string_literal: true

# Represents a credit card.
class Card
  attr_reader :number, :expiry_date, :cvv

  def initialize(number, expiry_date, cvv)
    @number = number
    @expiry_date = expiry_date
    @cvv = cvv
  end

  def to_s
    last_four_digits
  end

  private

  def last_four_digits
    @number[-4..]
  end
end
