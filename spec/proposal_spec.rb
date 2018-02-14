require_relative '../system/proposals/proposal'
require_relative '../system/proposals/repository'
require_relative 'test_support/fixture'

describe 'Created proposal' do
  it 'contains all data' do
    proposal = Proposal.new(id_proposal: Fixture::ID_PROPOSAL, proposer: Fixture::PROPOSER, involved: Fixture::INVOLVED, proposal: Fixture::PROPOSAL, domain_link: Fixture::DOMAIN_LINK, consensus_email: Fixture::CONSENSUS_EMAIL)
    expect(proposal.proposer).to eq(Fixture::PROPOSER)
    expect(proposal.involved).to eq(Fixture::INVOLVED)
    expect(proposal.proposal).to eq(Fixture::PROPOSAL)
    expect(proposal.id_proposal).to eq(Fixture::ID_PROPOSAL)
  end
end

describe 'The repository' do
  it 'saves a proposal' do
    proposal = Proposal.new(id_proposal: Fixture::ID_PROPOSAL, proposer: Fixture::PROPOSER, involved: Fixture::INVOLVED, proposal: Fixture::PROPOSAL, domain_link: Fixture::DOMAIN_LINK, consensus_email: Fixture::CONSENSUS_EMAIL)

    response = Proposals::Repository.save(proposal)

    expect(response.id_proposal).to eq(Fixture::ID_PROPOSAL)
  end

  it 'returns a proposal' do
    proposal = Proposal.new(id_proposal: Fixture::ID_PROPOSAL, proposer: Fixture::PROPOSER, involved: Fixture::INVOLVED, proposal: Fixture::PROPOSAL, domain_link: Fixture::DOMAIN_LINK, consensus_email: Fixture::CONSENSUS_EMAIL)
    Proposals::Repository.save(proposal)
    proposal2 = Proposal.new(id_proposal: Fixture::SECOND_ID_PROPOSAL, proposer: Fixture::PROPOSER, involved: Fixture::INVOLVED, proposal: Fixture::SECOND_PROPOSAL, domain_link: Fixture::DOMAIN_LINK, consensus_email: Fixture::CONSENSUS_EMAIL)
    Proposals::Repository.save(proposal2)

    response = Proposals::Repository.retrieve(Fixture::ID_PROPOSAL)
    second_response = Proposals::Repository.retrieve(Fixture::SECOND_ID_PROPOSAL)
    
    expect(response.proposal).to eq(Fixture::PROPOSAL)
    expect(second_response.proposal).to eq(Fixture::SECOND_PROPOSAL)
  end
end
