require 'securerandom'

class Proposal
  attr_reader :id_proposal, :proposer, :involved, :proposal, :domain_link, :consensus_email

  def self.from_document(document)
    Proposal.new(
      id_proposal: document[:id_proposal],
      proposer: document[:proposer],
      involved: document[:involved],
      proposal: document[:proposal],
      domain_link: document[:domain_link],
      consensus_email: document[:consensus_email]
    )
  end

  def initialize(id_proposal: nil,
      proposer:,
      involved:,
      proposal:,
      domain_link: DOMAIN_LINK,
      consensus_email: CONSENSUS_EMAIL)
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

  def serialize
    {
      id_proposal: @id_proposal,
      proposer: @proposer,
      involved: @involved,
      proposal: @proposal,
      domain_link: @domain_link,
      consensus_email: @consensus_email
    }
  end

  def create_id
    SecureRandom.uuid
  end
end
