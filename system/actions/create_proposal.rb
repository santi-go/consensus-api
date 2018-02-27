require_relative '../models/proposal'
require_relative '../repositories/proposals'
require_relative '../../system/notify'

module Actions
    class CreateProposal
      class << self
        def do(params)
            proposal = Proposal.new(proposer: params['proposer'],
                                    involved: params['circle'],
                                    proposal: params['proposal'])
            Repository::Proposals.save(proposal)
            Notify.do(proposal)
        end
      end
    end
end
