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
        result = []
        @@repository_data.each do |vote|
          if (vote.id_proposal == id_proposal && vote.user == user)
                result = vote
          end
        end
        return result
      end

      def count
        @@repository_data.count
      end

      def consensus_list(id_proposal)
        list= @@repository_data.select{|vote| vote.id_proposal == id_proposal}
        list.select{|vote| vote.decision == 'consensus'}
      end

      def disensus_list(id_proposal)
        list=@@repository_data.select{|vote| vote.id_proposal == id_proposal}
        list.select{|vote| vote.decision == 'disensus'}
      end

      def check_vote(vote)
        last_vote = retrieve(vote.id_proposal, vote.user)
        if (last_vote == [])
          save(vote)
        else
          update(last_vote, vote.decision)
        end
      end

      def update(last_vote, decision)
        last_vote.decision = decision
      end

      def voted(id_proposal, voted)
        votes = 0
        votes_from_proposal(id_proposal).each do |vote|
          (votes += 1) if vote.decision == voted
        end
        votes
      end

      def votes_from_proposal(id_proposal)
        @@repository_data.select{|vote| vote.id_proposal == id_proposal}
      end

      def count_votes(id_proposal)
        votes = 0
        @@repository_data.each do |vote|
          (votes += 1) if vote.id_proposal == id_proposal
        end
        votes
      end
    end
  end
end
