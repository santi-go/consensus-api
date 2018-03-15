class Fixture
  TEMPLATE_INVOLVED = Liquid::Template.parse(File.read("./templates/notification.liquid"))
  PROPOSER = 'proposer@sample.com'
  INVOLVED = ['proposer@sample.com', 'involved1@sample.com', 'involved2@sample.com']
  PROPOSAL = 'Its a sample proposal'
  SECOND_PROPOSAL = 'Second proposal'
  ID_PROPOSAL = '2018-1'
  SECOND_ID_PROPOSAL = '2018-2'
  DOMAIN_LINK = 'http://localhost:8080/reunion-consensus.html?'
  CIRCLE = ['involved1@sample.com', 'involved2@sample.com']
  RECIPIENT = 'correo1@domain.es'
  CONSENSUS_EMAIL = 'consensus@devscola.org'
  VOTE = 'consensus'
end
