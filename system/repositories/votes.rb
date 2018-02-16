module Repository
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

      def count
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

      def update(last_vote, decision)
        last_vote.vote = decision
      end
    end
  end
end
