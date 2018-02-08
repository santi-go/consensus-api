class Fixture
  TEMPLATE_INVOLVED = Liquid::Template.parse(File.read("./templates/involved.liquid"))
  PROPOSER = 'proposer@sample.com'
  INVOLVED = ['proposer@sample.com', 'involved1@sample.com', 'involved2@sample.com']
  PROPOSAL = 'Its a sample proposal'
  ID_PROPOSAL = '2018-1'
  DOMAIN_LINK = 'http://localhost:8080/reunion-consensus.html?'
  CIRCLE = INVOLVED.unshift(PROPOSER)
  RECIPIENT = 'correo1@domain.es'
  CONSENSUS_EMAIL = 'consensus@devscola.org'
end
