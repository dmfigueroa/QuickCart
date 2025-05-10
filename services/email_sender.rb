# frozen_string_literal: true

# Sends emails to customers.
class EmailSender
  def send_email(to, subject, _body)
    puts "Sending email to #{to} with subject #{subject}."
  end
end
