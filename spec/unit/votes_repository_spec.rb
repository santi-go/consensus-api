require_relative '../../system/models/vote'
require_relative '../../system/repositories/votes'
require_relative '../test_support/fixture'

describe 'Votes repository' , :unitarios do
  before(:each) do
    Repository::Votes.clear
  end

  after(:each) do
    Repository::Votes.clear
  end

  it 'saves and retrieves votes' do
    id_proposal = Fixture::ID_PROPOSAL
    user = Fixture::RECIPIENT
    vote = 'consensus'
    votation = Vote.new(id_proposal: id_proposal, user: user, decision: vote)
    second_votation = Vote.new(id_proposal: id_proposal, user: 'other@user.com', decision: 'disensus')

    saved_votation = Repository::Votes.save(votation)
    Repository::Votes.save(second_votation)

    retrieved_votes = Repository::Votes.retrieve(id_proposal, user)
    expect(retrieved_votes.serialize).to eq(saved_votation.serialize)
  end

  it 'update vote' do
    id_proposal = Fixture::ID_PROPOSAL
    user = Fixture::RECIPIENT
    vote = 'consensus'
    votation = Vote.new(id_proposal: id_proposal, user: user, decision: vote)

    saved_votation = Repository::Votes.save(votation)
    votation_before_update = saved_votation.serialize

    Repository::Votes.update(saved_votation, 'disensus')

    retrieved_votes = Repository::Votes.retrieve(id_proposal, user)
    retrieved_votes.serialize
    expect(retrieved_votes).not_to eq(votation_before_update)
  end
end
