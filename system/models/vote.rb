class Vote

  def initialize(id_proposal:, involved:, vote:)
    @id_proposal = id_proposal
    @involved = involved
    @vote = vote
    @date = Time.now.strftime("Last vote was in %d/%m/%Y - %T")
  end

end
