module Actions
  class Votation
    class << self
      def do (params)
        token = params['token']
        array = token.split('&')
        array_params = []
        array.each {|element| array_params << element.split('=')}
        hash = array_params.to_h

        user = hash['user']
        vote = hash['vote']
        id_proposal = hash['id_proposal']

        retrieved_proposal = Repository::Proposals.retrieve(id_proposal)
        save_vote(id_proposal, user, vote)
        notify_votation_state(retrieved_proposal[0], user)

        response_to_invited = {
          :user => user.to_s,
          :proposer => retrieved_proposal[0].proposer,
          :vote => vote.to_s,
          :proposal_text => retrieved_proposal[0].proposal,
          :id_proposal => id_proposal.to_s
        }.to_json
        response_to_invited
      end

      def save_vote(id_proposal, user, vote)
        new_vote = Vote.new(id_proposal: id_proposal,
                          user: user,
                          vote: vote)
        Repository::Votes.check_vote(new_vote)
        new_vote
      end

      def notify_votation_state(retrieved_proposal, user)
        Notify.votation_state(retrieved_proposal, user)
      end
    end
  end
end
