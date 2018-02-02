require 'mail'

class Communication
  Mail.defaults do
    delivery_method :smtp, {
      address: 'smtp.sendgrid.net',
      port: 25,
      user_name: 'apikey',
      password: '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',
      return_response: true
    }
  end

  def send_mail(from, list_to, subject, involved_body, proposer, proposer_body)
    list_to.each do |email|
      mail = Mail.new
      mail.from = from
      mail.subject = subject
      mail.content_type = 'text/html; charset=UTF-8'
      if (email == proposer)
        mail.body = proposer_body
      else
        mail.body = involved_body
      end
      mail.to = email
      mail.deliver!
    end
  end
end
