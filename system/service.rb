class Communication
  Mail.defaults do
    delivery_method :smtp, {
      address: 'smtp.sendgrid.net',
      port: 25,
      user_name: 'apikey',
      password: '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'
    }
  end

  def send_mail(from, list_to, subject, body)
    list_to.each do |email|
      mail = Mail.new
      mail.from = from
      mail.subject = subject
      mail.content_type = 'text/html; charset=UTF-8'
      mail.body = body

      mail.to = email
      mail.deliver!
    end
  end

  def remove_repeated_emails(circle, proposer)
    cleaned_circle = []
    list = circle + [proposer]
    list.each do
      |element| cleaned_circle << element unless cleaned_circle.include?(element)
    end
    cleaned_circle
  end
end
