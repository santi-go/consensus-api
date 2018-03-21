require 'base64'
require_relative '../notify'

module Actions
  class VoteAction
    class << self
      def do(params)
        hash_params = prepare_params(params).to_h
        id_proposal = hash_params['id_proposal']
        user = hash_params['user']
        decision = hash_params['decision']
        return result_of_vote(id_proposal, user, decision)
      end

      def prepare_params(params)
        token = params['token']
        token_uncoded = decode(token)
        token_splitted = token_uncoded.split('&')
        array_params = []
        token_splitted.each {|element| array_params << element.split('=')}
        return array_params
      end

      def result_of_vote(id_proposal, user, decision)
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
          default_response = create_response(retrieved_proposal, user, decision)
          save_vote(retrieved_proposal.id_proposal, user, decision)
          notify_votation_state(retrieved_proposal, user)
        end
        return default_response.to_json
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

      def save_vote(id_proposal, user, decision)
        voted = create_the_vote(id_proposal, user, decision)
        last_vote = retrieve_the_vote(voted)
        return save_the_vote(voted) if (last_vote == [])
        update_the_vote(last_vote, voted.decision)
      end

      def notify_votation_state(retrieved_proposal, user)
        Notify.votation_state(retrieved_proposal, user)
      end

      def decode(token)
        Base64.strict_decode64(token)
      end

      private

      def create_the_vote(id_proposal, user, decision)
        Vote.new(id_proposal: id_proposal, user: user, decision: decision)
      end

      def retrieve_the_vote(vote)
        Repository::Votes.retrieve(vote.id_proposal, vote.user)
      end

      def save_the_vote(vote)
        Repository::Votes.save(vote)
      end

      def update_the_vote(last_vote, decision)
        Repository::Votes.update(last_vote, decision)
      end
    end
  end
end
