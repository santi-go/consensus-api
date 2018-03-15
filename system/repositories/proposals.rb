require_relative '../models/proposal'
require_relative '../infrastructure/client'

module Repository
  class Proposals
    class << self
      def save(proposal)
        Infrastructure::Client.insert_one(proposal.serialize)
        return proposal
      end

      def clear
        Infrastructure::Client.flush
      end

      def retrieve(id_proposal)
        proposal = Infrastructure::Client.find_one(id_proposal)
        Proposal.from_document(proposal)
      end

      def user_included?(id_proposal, user)
        proposal_retrieved = Infrastructure::Client.find_one(id_proposal)
        proposal = Proposal.from_document(proposal_retrieved)
        proposal.involved.include?(user)
      end
    end
  end
end
