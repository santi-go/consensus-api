module Repository

  class Proposals
    class << self
      @@repository_data ||= []

      def save(proposal)
        @@repository_data << proposal
        return proposal
      end

      def proposal_count
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

  class Votes
    class << self
      @@repository_data ||= []

      def save(vote)
        @@repository_data << vote
        return vote
      end

      def repository_data
        @@repository_data
      end

      def clear
        @@repository_data = []
      end

      def retrieve(id_proposal, user)
        result = @@repository_data.each do |vote|
          return vote if (vote.id_proposal == id_proposal && vote.user == user)
        end
        if (result.length != 1)
           return nil
        else
          return result
        end
      end

      def vote_count
        @@repository_data.count
      end

      def check_vote(vote)
        last_vote = retrieve(vote.id_proposal, vote.user)
        if (last_vote == nil || last_vote == [])
          save(vote)
        else
          update(last_vote, vote.vote)
        end
      end

      def update(decision)
        last_vote.vote = decision
      end
    end
  end
end
