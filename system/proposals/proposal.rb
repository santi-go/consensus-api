require 'securerandom'

class Proposal
  attr_reader :id_proposal, :proposer, :involved, :proposal, :domain_link, :consensus_email

  def initialize(id_proposal, proposer, involved, proposal, domain_link, consensus_email)
    @id_proposal = create_id(id_proposal)
    @proposer = proposer
    @involved = involved
    @proposal = proposal
    @domain_link = domain_link
    @consensus_email = consensus_email
  end

  def create_id(id_proposal)
    identify = SecureRandom.uuid
    identify = id_proposal if !(id_proposal == nil)
    return identify
  end
end
