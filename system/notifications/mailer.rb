require 'mail'

module Notifications
  class Mailer
    def self.deliver(origin, destiny, subject, body)
      mail = Mail.new
      mail.from = origin
      mail.to = destiny
      mail.subject = subject
      mail.body = body
      mail.content_type = 'text/html; charset=UTF-8'
      mail.deliver!
    end
  end
end
