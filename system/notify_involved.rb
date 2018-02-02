require 'liquid'

require_relative 'email_sender'
require_relative 'subject'

class Notify_involved
  class << self
    def do(involved, proposal, proposer)
      consensus_to = to_notify(involved, proposer)
      consensus_subject = Subject.create(proposal)
      involved_body = template_for_involved(consensus_to, proposer, proposal)
      proposer_body = template_for_proposer(consensus_to, proposer, proposal)

      communication = Communication.new
      consensus_email = 'consensus@devscola.org'
      communication.send_mail(consensus_email, consensus_to, consensus_subject, involved_body, proposer, proposer_body)
    end

    def to_notify(involved, proposer)
      involved.unshift(proposer)
      involved.uniq
    end

    def template_for_involved(consensus_to, proposer, proposal)
      consensus_to_beautified = consensus_to.to_s.gsub(/[\"\[\]]/,"")
      template = Liquid::Template.parse(File.read("./templates/proposer_email.liquid"))
      consensus_body = template.render(
        'proposer' => proposer,
        'involved' => consensus_to_beautified,
        'proposal' => proposal
      )
    end

    def template_for_proposer(consensus_to, proposer, proposal)
      consensus_to_beautified = consensus_to.to_s.gsub(/[\"\[\]]/,"")
      template = Liquid::Template.parse(File.read("./templates/proposer.liquid"))
      consensus_body = template.render(
        'proposer' => proposer,
        'involved' => consensus_to_beautified,
        'proposal' => proposal
      )
    end
  end
end
