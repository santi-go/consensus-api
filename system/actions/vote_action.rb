require_relative '../notify'

module Actions
  class VoteAction
    class << self
      def do(params)
        hash_params = prepare_params(params).to_h
        return create_vote_response(hash_params)
      end

      def prepare_params(params)
        token = params['token']
        token_splitted = token.split('&')
        array_params = []
        token_splitted.each {|element| array_params << element.split('=')}
        return array_params
      end

      def create_vote_response(hash_params)
        id_proposal = hash_params['id_proposal']
        user = hash_params['user']
        vote = hash_params['decision']

        prepared_response = {
          'user' => user,
          'proposer' => 'HACKER MAN',
          'decision' => 'OUTSIDE THE BALLOT BOX',
          'proposal_text' => 'DOES NOT EXIST ',
          'id_proposal' => id_proposal
        }

        retrieved_proposal = Repository::Proposals.retrieve(id_proposal)

        if !(retrieved_proposal == [])
          prepared_response['proposer'] = retrieved_proposal.proposer
          prepared_response['proposal'] = retrieved_proposal.proposal
          user_is_included_in_proposal = Repository::Proposals.user_included?(id_proposal, user)
          if (user_is_included_in_proposal == true)
            save_vote(id_proposal, user, vote)
            notify_votation_state(retrieved_proposal, user)
          end
        end

        return prepared_response.to_json
      end

      def save_vote(id_proposal, user, vote)
        new_vote = Vote.new(id_proposal: id_proposal,
                          user: user,
                          decision: vote)
        Repository::Votes.check_vote(new_vote)
        new_vote
      end

      def notify_votation_state(retrieved_proposal, user)
        Notify.votation_state(retrieved_proposal, user)
      end
    end
  end
end
