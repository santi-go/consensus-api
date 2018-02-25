require 'liquid'

require_relative 'communication'
require_relative 'subject'

class Notify
  class << self
    def do(new_proposal)
      consensus_to = circle(new_proposal.involved, new_proposal.proposer)
      consensus_subject = Subject.create(new_proposal.proposal)

      consensus_to.each do |mail_to|
        template = select_template(mail_to, new_proposal.proposer)
        consensus_body = body_constructor(new_proposal, mail_to, template)
        Communication.deliver(new_proposal.consensus_email, mail_to, consensus_subject, consensus_body)
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

    def body_constructor(new_proposal, mail_to, template)
      circle_beautified = beautify_list(circle(new_proposal.involved, new_proposal.proposer))
      consensus_body = template.render(
        'proposer' => new_proposal.proposer,
        'involved' => circle_beautified,
        'id_proposal' => new_proposal.id_proposal,
        'proposal' => new_proposal.proposal,
        'recipient' => mail_to,
        'domain_link' => new_proposal.domain_link
      )
      @body = consensus_body
    end

    def beautify_list(list)
      list.to_s.gsub(/[\"\[\]]/,"")
    end

    def get_body
      @body
    end

    def votation_state(proposal_array, user)
      proposal = proposal_array
      from = 'consensus@devscola.org'
      mail_to = proposal.proposer
      subject = Subject.create(proposal.proposal)
      circle_beautified = beautify_list(circle(proposal.involved, proposal.proposer))
      template = Liquid::Template.parse(File.read("./templates/proposer-votes.liquid"))
      consensus_votes = Repository::Votes.voted(proposal.id_proposal, 'consensus')
      disensus_votes = Repository::Votes.voted(proposal.id_proposal, 'disensus')
      body = template.render(
        'proposer' => mail_to,
        'involved' => circle_beautified,
        'last_voter' => user,
        'total_consensus' => consensus_votes ,
        'total_disensus' => disensus_votes,
        'proposal' => proposal.proposal
        )
      Communication.deliver(from, mail_to, subject, body)
    end
  end
end
