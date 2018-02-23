require_relative '../system/repositories/repository'
require_relative '../system/models/vote'
require_relative 'test_support/fixture'

describe 'Vote' do
  it 'saves a vote in a repository' do
    vote = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: Fixture::RECIPIENT, vote: Fixture::VOTE)

    Repository::Votes.save(vote)

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

  it 'returns all votes' do
    Repository::Votes.clear
    vote1 = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: 'uno', vote: 'consensus')
    Repository::Votes.save(vote1)
    vote2 = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: 'dos', vote: 'consensus')
    Repository::Votes.save(vote2)
    vote3 = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: 'tres', vote: 'disensus')
    Repository::Votes.save(vote3)

    total_voted = Repository::Votes.count_votes(Fixture::ID_PROPOSAL)
    voted_consensus = Repository::Votes.voted(Fixture::ID_PROPOSAL, 'consensus')
    voted_disensus = Repository::Votes.voted(Fixture::ID_PROPOSAL, 'disensus')
    expect(voted_consensus).to eq(2)
    expect(voted_disensus).to eq(1)
    expect(total_voted).to eq(3)
  end

end
