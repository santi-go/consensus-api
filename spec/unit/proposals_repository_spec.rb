require_relative '../../system/models/proposal'
require_relative '../../system/repositories/proposals'

describe 'Proposals repository' do
  before(:each) do
    Repository::Proposals.clear
  end

  after(:each) do
    Repository::Proposals.clear
  end

  it 'saves and retrieves proposals' do
    id = 'Some id of proposal'
    proposal = Proposal.new(id_proposal: id, proposer: nil, involved: nil, proposal: nil)

    Repository::Proposals.save(proposal)

    retrieved_proposal = Repository::Proposals.retrieve(id)
    expect(retrieved_proposal.serialize).to eq(proposal.serialize)
  end

  it 'knows if user is included' do
    id = 'Some id of proposal'
    user = 'user@existent.com'
    proposal = Proposal.new(id_proposal: id, proposer: nil, involved: [user], proposal: nil)
    Repository::Proposals.save(proposal)

    result = Repository::Proposals.user_included?(id, user)

    expect(result).to be(true)
  end
end
