require 'liquid'
require 'mail'

require_relative 'email_sender'
require_relative 'subject'

class Notify_involved
  class << self
    def do(involved, proposal, proposer)
      consensus_to = to_notify(involved, proposer)

      consensus_subject = Subject.create(proposal)

      consensus_to_beautified = consensus_to.to_s.gsub(/[\"\[\]]/,"")
      template = Liquid::Template.parse(File.read("./templates/proposer_email.liquid"))
      consensus_body = template.render(
        'proposer' => proposer,
        'involved' => consensus_to_beautified,
        'proposal' => proposal
      )
      communication = Communication.new
      consensus_email = 'consensus@devscola.org'
      communication.send_mail(consensus_email, consensus_to, consensus_subject, consensus_body)

    end

    def to_notify(involved, proposer)
      involved << proposer
      involved.uniq
    end


  end
end
