require 'base64'
require_relative '../notify'

module Actions
  class VoteAction
    class << self
      def do(params)
        hash_params = prepare_params(params).to_h
        return result_of_vote(hash_params)
      end

      def prepare_params(params)
        token = params['token']
        token_uncoded = decode(token)
        token_splitted = token_uncoded.split('&')
        array_params = []
        token_splitted.each {|element| array_params << element.split('=')}
        return array_params
      end

      def result_of_vote(hash_params)
        id_proposal = hash_params['id_proposal']
        user = hash_params['user']
        vote = hash_params['decision']

        default_response = {
          'user' => 'HACKER MAN',
          'proposer' => 'NONE',
          'decision' => 'OUTSIDE THE BALLOT BOX',
          'proposal_text' => 'DOES NOT EXIST ',
          'id_proposal' => 'NOTHING'
        }

        retrieved_proposal = Repository::Proposals.retrieve(id_proposal)
        user_is_included_in_proposal = Repository::Proposals.user_included?(id_proposal, user) if !(retrieved_proposal == [])
        if (user_is_included_in_proposal == true)
          default_response = create_response(retrieved_proposal, user, vote)
          save_vote(retrieved_proposal.id_proposal, user, vote)
          notify_votation_state(retrieved_proposal, user)
        end
        return default_response.to_json
      end

      def decode(token)
        Base64.strict_decode64(token)
      end

      def create_response(retrieved_proposal, user, vote)
        return {
          'user' => user,
          'proposer' => retrieved_proposal.proposer,
          'decision' => vote,
          'proposal_text' => retrieved_proposal.proposal,
          'id_proposal' => retrieved_proposal.id_proposal
        }
      end

      def save_vote(id_proposal, user, vote)
        new_vote = Vote.new(id_proposal: id_proposal,
                          user: user,
                          decision: vote)
        Repository::Votes.save_or_update(new_vote)
        new_vote
      end

      def notify_votation_state(retrieved_proposal, user)
        Notify.votation_state(retrieved_proposal, user)
      end
    end
  end
end
