require 'liquid'

require_relative 'email_sender'
require_relative 'subject'

class Notify_involved
  class << self
    def do(proposer, involved, proposal, domain_link, id_proposal)
      consensus_to = to_notify(involved, proposer)
      consensus_subject = Subject.create(proposal)
      consensus_email = 'consensus@devscola.org'

      communication = Communication.new
      consensus_to.each do |recipient|

        body_data = {
          :proposer => proposer,
          :consensus_to => consensus_to,
          :proposal => proposal,
          :domain_link => domain_link,
          :id_proposal => id_proposal,
          :recipient => recipient
        }

        consensus_body = body_constructor(body_data)
        communication.send_mail(consensus_email, consensus_to, consensus_subject, consensus_body, body_data[:recipient])
      end
    end

    def to_notify(involved, proposer)
      involved << proposer
      involved.uniq
    end

    def body_constructor(body_data)
      template = Liquid::Template.parse(File.read("./templates/proposer_email.liquid"))
      consensus_to_beautified = body_data[:consensus_to].to_s.gsub(/[\"\[\]]/,"")

      consensus_body = template.render(
        'proposer' => body_data[:proposer],
        'involved' => consensus_to_beautified,
        'id_proposal' => body_data[:id_proposal],
        'proposal' => body_data[:proposal],
        'recipient' => body_data[:recipient],
        'domain_link' => body_data[:domain_link]
      )

      consensus_body
    end

  end
end
