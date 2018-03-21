module Repository
  class Votes
    class << self
      @repository_data ||= []

      def save(vote)
        @repository_data << vote
        return vote
      end

      def repository_data
        @repository_data
      end

      def clear
        @repository_data = []
      end

      def retrieve(id_proposal, user)
        result = []
        @repository_data.each do |vote|
          if (vote.id_proposal == id_proposal && vote.user == user)
                result = vote
          end
        end
        return result
      end

      def update(last_vote, decision)
        change_vote = retrieve(last_vote.id_proposal, last_vote.user)
        change_vote.decision = decision
      end

      def consensus_count(id_proposal)
        consensus_list(id_proposal).count
      end

      def disensus_count(id_proposal)
        disensus_list(id_proposal).count
      end

      def votes_from_proposal(id_proposal)
        @repository_data.select{|vote| vote.id_proposal == id_proposal}
      end

      def save_or_update(vote)
        last_vote = retrieve(vote.id_proposal, vote.user)
        if (last_vote == [])
          save(vote)
        else
          update(last_vote, vote.decision)
        end
      end

      private

      def consensus_list(id_proposal)
        votes_from_proposal(id_proposal).select{|vote| vote.decision == 'consensus'}
      end

      def disensus_list(id_proposal)
        votes_from_proposal(id_proposal).select{|vote| vote.decision == 'disensus'}
      end

    end
  end
end
