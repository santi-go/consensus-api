module Repository
  class Proposals
    class << self
      @@Repository_data ||= []

      def save(proposal)
        @@Repository_data << proposal
        return proposal
      end

      def retrieve(id_proposal)
        @@Repository_data.each do |proposal|
          return proposal if proposal.id_proposal == id_proposal
        end
      end
    end
  end
end
