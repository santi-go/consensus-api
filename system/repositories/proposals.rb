module Repository

  class Proposals
    class << self
      @@repository_data ||= []

      def save(proposal)
        @@repository_data << proposal
        return proposal
      end

      def count
        @@repository_data.count
      end

      def clear
        @@repository_data = []
      end

      def retrieve(id_proposal)
        result = []
        @@repository_data.each do |proposal|
          if proposal.id_proposal == id_proposal
            result = proposal
          end
        end
        return result
      end

      def user_included?(id_proposal, user)
        proposal_retrieved = self.retrieve(id_proposal)
        proposal_retrieved.involved.include?(user)
      end
    end
  end
end
