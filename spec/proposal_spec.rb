require_relative '../system/proposal'
require_relative 'test_support/fixture'

describe 'Created proposal' do
  it 'contains all data' do
    proposal = Proposal.new(Fixture::ID_PROPOSAL, Fixture::PROPOSER, Fixture::INVOLVED, Fixture::PROPOSAL, Fixture::DOMAIN_LINK, Fixture::CONSENSUS_EMAIL)

    expect(proposal.proposer).to eq(Fixture::PROPOSER)
    expect(proposal.involved).to eq(Fixture::INVOLVED)
    expect(proposal.proposal).to eq(Fixture::PROPOSAL)
    expect(proposal.id_proposal).to eq(Fixture::ID_PROPOSAL)
  end
end
