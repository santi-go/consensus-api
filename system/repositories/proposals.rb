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
        @@repository_data.each do |proposal|
          return proposal if proposal.id_proposal == id_proposal
        end
      end
    end
  end
end
