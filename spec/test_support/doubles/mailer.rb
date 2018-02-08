module TestSupport
  module Doubles
    class Mailer
      class << self
        def deliver(origin, destiny, subject, body)
          @first_origin ||= origin
          @count ||= 0
          @count += 1
          @last_sent_body = body

          @delivered_mail = {
            origin: origin,
            destiny: destiny,
            subject: subject,
            body: body
          }
        end

        def delivered_mail
          @delivered_mail
        end

        def delivered_count
          @count
        end

        def clear
          @count = 0
          @first_origin = nil
        end

        def origin
          @first_origin
        end

        def last_sent_body
          @last_sent_body
        end
      end
    end
  end
end
