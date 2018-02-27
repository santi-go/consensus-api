require_relative '../system/repositories/proposals'
require_relative '../system/repositories/votes'
require_relative '../system/models/vote'
require_relative 'test_support/fixture'

describe 'Vote' do
  it 'saves a vote in a repository' do
    vote = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: Fixture::RECIPIENT, decision: Fixture::VOTE)

    Repository::Votes.save(vote)

    expect(vote.id_proposal).to eq(Fixture::ID_PROPOSAL)
  end

  it 'returns a vote' do
    vote = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: Fixture::RECIPIENT, decision: Fixture::VOTE)
    Repository::Votes.save(vote)
    vote2 = Vote.new(id_proposal: Fixture::SECOND_ID_PROPOSAL, user: Fixture::RECIPIENT, decision: Fixture::VOTE)
    Repository::Votes.save(vote2)

    response = Repository::Votes.retrieve(Fixture::ID_PROPOSAL, Fixture::RECIPIENT)
    second_response = Repository::Votes.retrieve(Fixture::SECOND_ID_PROPOSAL, Fixture::RECIPIENT)

    expect(response.id_proposal).to eq(Fixture::ID_PROPOSAL)
    expect(second_response.id_proposal).to eq(Fixture::SECOND_ID_PROPOSAL)
  end

  it 'returns all votes' do
    Repository::Votes.clear
    vote1 = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: 'uno', decision: 'consensus')
    Repository::Votes.save(vote1)
    vote2 = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: 'dos', decision: 'consensus')
    Repository::Votes.save(vote2)
    vote3 = Vote.new(id_proposal: Fixture::ID_PROPOSAL, user: 'tres', decision: 'disensus')
    Repository::Votes.save(vote3)

    total_voted = Repository::Votes.count_votes(Fixture::ID_PROPOSAL)
    voted_consensus = Repository::Votes.voted(Fixture::ID_PROPOSAL, 'consensus')
    voted_disensus = Repository::Votes.voted(Fixture::ID_PROPOSAL, 'disensus')
    expect(voted_consensus).to eq(2)
    expect(voted_disensus).to eq(1)
    expect(total_voted).to eq(3)
  end

  it 'belongs to an independent proposal' do
    Repository::Votes.clear
    first_proposal = Proposal.new(
      proposer: Fixture::PROPOSER,
      involved: Fixture::INVOLVED,
      proposal: Fixture::PROPOSAL,
      domain_link: Fixture::DOMAIN_LINK,
      consensus_email: Fixture::CONSENSUS_EMAIL
    )
    second_proposal = Proposal.new(
      proposer: Fixture::PROPOSER,
      involved: Fixture::INVOLVED,
      proposal: Fixture::SECOND_PROPOSAL,
      domain_link: Fixture::DOMAIN_LINK,
      consensus_email: Fixture::CONSENSUS_EMAIL
    )

    first_vote = Vote.new(id_proposal: first_proposal.id_proposal, user: 'uno', decision: 'consensus')
    Repository::Votes.save(first_vote)
    second_vote = Vote.new(id_proposal: second_proposal.id_proposal, user: 'uno', decision: 'disensus')
    Repository::Votes.save(second_vote)

    first_proposal_consensus_quantity = Repository::Votes.voted(first_proposal.id_proposal, 'consensus')
    first_proposal_disensus_quantity = Repository::Votes.voted(first_proposal.id_proposal, 'disensus')
    second_proposal_consensus_quantity = Repository::Votes.voted(second_proposal.id_proposal, 'consensus')
    second_proposal_disensus_quantity = Repository::Votes.voted(second_proposal.id_proposal, 'disensus')

    expect(first_proposal_consensus_quantity).to eq(1)
    expect(first_proposal_disensus_quantity).to eq(0)
    expect(second_proposal_consensus_quantity).to eq(0)
    expect(second_proposal_disensus_quantity).to eq(1)
  end
end
