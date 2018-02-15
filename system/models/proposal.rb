require 'securerandom'

class Proposal
  attr_reader :id_proposal, :proposer, :involved, :proposal, :domain_link, :consensus_email

  def initialize(id_proposal: nil, proposer:, involved:, proposal:, domain_link:, consensus_email:)
    @id_proposal = check_id(id_proposal)
    @proposer = proposer
    @involved = involved
    @proposal = proposal
    @domain_link = domain_link
    @consensus_email = consensus_email
  end

  def check_id(id_proposal)
    return id_proposal if (id_proposal != nil)
    create_id
  end

  def create_id
    SecureRandom.uuid
  end
end
