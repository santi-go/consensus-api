require_relative '../system/models/repository'
require_relative '../system/models/vote'
require_relative 'test_support/fixture'

describe 'Vote' do
  it 'saves a vote in a repository' do
    vote = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: Fixture::RECIPIENT, vote: Fixture::VOTE)

    response = Repository::Votes.save(vote)

    expect(vote.id_proposal).to eq(Fixture::ID_PROPOSAL)
  end

  it 'returns a vote' do
    vote = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: Fixture::RECIPIENT, vote: Fixture::VOTE)
    Repository::Votes.save(vote)
    vote2 = Vote.new(id_proposal: Fixture::SECOND_ID_PROPOSAL, user: Fixture::RECIPIENT, vote: Fixture::VOTE)
    Repository::Votes.save(vote2)

    response = Repository::Votes.retrieve(Fixture::ID_PROPOSAL, Fixture::RECIPIENT)
    second_response = Repository::Votes.retrieve(Fixture::SECOND_ID_PROPOSAL, Fixture::RECIPIENT)

    expect(response.id_proposal).to eq(Fixture::ID_PROPOSAL)
    expect(second_response.id_proposal).to eq(Fixture::SECOND_ID_PROPOSAL)
  end
end
