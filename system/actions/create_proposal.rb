require_relative '../models/proposal'
require_relative '../repositories/proposals'
require_relative '../../system/notify'

module Actions
    class CreateProposal
      class << self
        def do(params)
            domain = 'http://localhost:8080/'
            link = 'reunion-consensus.html?'
            domain_link = domain + link
            consensus_email = 'consensus@devscola.org'
            proposal = Proposal.new(proposer: params['proposer'],
                                    involved: params['circle'],
                                    proposal: params['proposal'],
                                    domain_link: domain_link,
                                    consensus_email: consensus_email)
            Repository::Proposals.save(proposal)
            Notify.do(proposal)
        end
      end
    end
end
