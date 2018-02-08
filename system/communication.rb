require_relative 'notifications/mailer'

class Communication
  def self.deliver(from, mail_to, subject, body)
    Notifications::Mailer.deliver(from, mail_to, subject, body)
  end
end
