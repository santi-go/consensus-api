require_relative '../notify'
require_relative '../repositories/votes'
require_relative '../helpers/enigma'

module Actions
  class VoteAction
    class << self
      def do(id_proposal, user, decision)
        process_vote(id_proposal, user, decision)
      end

      private

      def process_vote(id_proposal, user, decision)
        response = default_response
        retrieved_proposal = Repository::Proposals.retrieve(id_proposal)
        user_is_included_in_proposal = Repository::Proposals.user_included?(id_proposal, user) if !(retrieved_proposal == [])
        if (user_is_included_in_proposal == true)
          response = create_response(retrieved_proposal, user, decision)
          vote(retrieved_proposal.id_proposal, user, decision)
          notify_votation_state(retrieved_proposal, user)
        end
        return response.to_json
      end

      def create_response(retrieved_proposal, user, decision)
        return {
          'user' => user,
          'proposer' => retrieved_proposal.proposer,
          'decision' => decision,
          'proposal_text' => retrieved_proposal.proposal,
          'id_proposal' => retrieved_proposal.id_proposal
        }
      end

      def vote(id_proposal, user, decision)
        Repository::Votes.vote(id_proposal, user, decision)
      end

      def notify_votation_state(retrieved_proposal, user)
        Notify.votation_state(retrieved_proposal, user)
      end

      def default_response
        return {
          'user' => 'HACKER MAN',
          'proposer' => 'NONE',
          'decision' => 'OUTSIDE THE BALLOT BOX',
          'proposal_text' => 'DOES NOT EXIST ',
          'id_proposal' => 'NOTHING'
        }
      end
    end
  end
end
