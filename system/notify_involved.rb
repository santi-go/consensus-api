require 'liquid'

require_relative 'email_fields'

class Notify_involved
  def self.do(consensus_to, proposal, proposer)
    consensus_to_beautified = consensus_to.to_s.gsub(/[\"\[\]]/,"")
    template = Liquid::Template.parse(File.read("./templates/proposer_email.liquid"))
    consensus_body = template.render(
      'proposer' => proposer,
      'circle' => consensus_to_beautified,
      'proposal' => proposal
    )
    return consensus_body
  end
end
