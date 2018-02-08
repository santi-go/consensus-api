module TestSupport
  module Doubles
    class Mail
      def from=(origin)
        @origin = origin
      end

      def to=(destiny)
        @destiny = destiny
      end

      def subject=(subject)
        @subject = subject
      end

      def body=(body)
        @body = body
      end

      def content_type=(_)
      end

      def deliver!
        self
      end

      def delivered
        {
          origin: @origin,
          destiny: @destiny,
          subject: @subject,
          body: @body
        }
      end
    end
  end
end
