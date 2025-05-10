class Card
  attr_reader :number, :expiry_date, :cvv

  def initialize(number, expiry_date, cvv)
    @number = number
    @expiry_date = expiry_date
    @cvv = cvv
  end

  def to_s
    "Card -> #{mask_number}"
  end

  private

  def mask_number
    "#### #### #### #{last_four_digits}"
  end

  def last_four_digits
    @number[-4..]
  end
end
