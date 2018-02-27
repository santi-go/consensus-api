class Vote
  attr_reader :id_proposal, :user
  attr_accessor :decision

  def initialize(id_proposal:, user:, decision:)
    @id_proposal = id_proposal
    @user = user
    @decision = decision
    @date = Time.now.strftime("%d/%m/%Y - %T")
  end
end
