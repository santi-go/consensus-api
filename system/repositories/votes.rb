require_relative '../models/vote'
require_relative '../infrastructure/client_votes'

module Repository
  class Votes
    class << self
      def clear
        Infrastructure::Client_votes.flush
      end

      def vote(id_proposal, user, decision)
        voted = create_the_vote(id_proposal, user, decision)
        exist_votation = user_as_voted?(voted.id_proposal, voted.user)
        if (exist_votation)
          the_vote = retrieve(voted.id_proposal, voted.user)
          update_vote = update(the_vote, voted.decision)
        else
          save(voted)
        end
      end

      def create_the_vote(id_proposal, user, decision)
        Vote.new(id_proposal: id_proposal, user: user, decision: decision)
      end

      def save(vote)
        Infrastructure::Client_votes.insert_one(vote.serialize)
        return vote
      end

      def retrieve(id_proposal, user)
        vote = Infrastructure::Client_votes.find_one(id_proposal, user)
        Vote.from_document(vote)
      end

      def update(last_vote, decision)
        Infrastructure::Client_votes.update(last_vote, decision)
      end

      def user_as_voted?(id_proposal, user)
        votation_exist = true
        total_votes = Infrastructure::Client_votes.count_user_votes(id_proposal, user)
        (votation_exist = false) if (total_votes != 1)
        return votation_exist
      end

      def consensus_count(id_proposal)
        contador = Infrastructure::Client_votes.count_decision(id_proposal, 'consensus')
        contador
      end

      def disensus_count(id_proposal)
        Infrastructure::Client_votes.count_decision(id_proposal, 'disensus')
      end
    end
  end
end
