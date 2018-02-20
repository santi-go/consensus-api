class Vote
  attr_reader :id_proposal, :user
  attr_accessor :vote

  def initialize (id_proposal:, user:, vote:)
    @id_proposal = id_proposal
    @user = user
    @vote = vote
    @date = Time.now.strftime("%d/%m/%Y - %T")
  end
end
