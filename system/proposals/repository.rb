module Proposals
  class Repository
    class << self
      @@proposals_data ||= []

      def save(proposal)
        @@proposals_data << proposal
        return proposal
      end

      def retrieve(id_proposal)
        @@proposals_data.each do |proposal|
          return proposal if proposal.id_proposal == id_proposal
        end
      end
    end
  end
end
