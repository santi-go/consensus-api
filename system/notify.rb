require 'liquid'

require_relative 'communication'
require_relative 'subject'

class Notify
  class << self
    def do(proposer, involved, proposal, domain_link, id_proposal)
      communication = Communication.new
      consensus_to = circle(involved, proposer)
      consensus_subject = Subject.create(proposal)
      consensus_email = 'consensus@devscola.org'
      consensus_to.each do |mail_to|
        body_data = {
          :proposer => proposer,
          :consensus_to => consensus_to,
          :proposal => proposal,
          :domain_link => domain_link,
          :id_proposal => id_proposal,
          :recipient => mail_to
          }
        template = select_template(mail_to, proposer)
        consensus_body = body_constructor(body_data, template)
        communication.send_mail(consensus_email, mail_to, consensus_subject, consensus_body)
      end
    end

    def circle(involved, proposer)
      involved.unshift(proposer)
      involved.uniq
    end

    def select_template(recipient, proposer)
      if recipient == proposer
        Liquid::Template.parse(File.read("./templates/proposer.liquid"))
      else
        Liquid::Template.parse(File.read("./templates/involved.liquid"))
      end
    end

    def body_constructor(body_data, template)
      consensus_to_beautified = body_data[:consensus_to].to_s.gsub(/[\"\[\]]/,"")
      consensus_body = template.render(
        'proposer' => body_data[:proposer],
        'involved' => consensus_to_beautified,
        'id_proposal' => body_data[:id_proposal],
        'proposal' => body_data[:proposal],
        'recipient' => body_data[:recipient],
        'domain_link' => body_data[:domain_link]
      )
      @body = consensus_body
    end

    def get_body
      @body
    end
  end
end
