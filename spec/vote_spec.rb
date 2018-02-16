require_relative '../system/models/repository'
require_relative '../system/models/vote'
require_relative 'test_support/fixture'

describe 'Vote' do
  xit 'saves a vote in a Proposals' do
    vote = Vote.new(id_proposal: Fixture::ID_PROPOSAL, involved: Fixture::INVOLVED, vote: Fixture::VOTE)

    response = Repository::Proposals.save(vote)

    expect(vote.id_proposal).to eq(Fixture::ID_PROPOSAL)
  end

end
