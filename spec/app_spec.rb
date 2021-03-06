require 'json'
require 'rack/test'

require_relative '../app.rb'
require_relative 'test_support/fixture'
require_relative 'test_support/doubles/mailer'
require_relative '../system/notify'
require_relative '../system/repositories/votes'

include Rack::Test::Methods

def app
  App
end

describe 'Send mail endpoint' do

  before(:each) do
    TestSupport::Doubles::Mailer.clear
    Repository::Proposals.clear
  end

  after(:each) do
    TestSupport::Doubles::Mailer.clear
    Repository::Proposals.clear
  end

  it 'accepts a json with required parameters' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    body = {
            'proposer': 'proposer@proposer.es',
            'circle': ['involved@involved.es'],
            'proposal': 'some_proposal'
    }

    post '/create-proposal', body.to_json

    expect(last_response).to be_ok
  end

  it ' does not accept a json without the required parameters' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    body = {
            'circle': ['involved@involved.es'],
            'proposal': 'some_proposal'
    }

    post '/create-proposal', body.to_json

    expect(last_response.status).to be(422)
  end

  it 'uses the consensus default email as sender email' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    request_body = {
                  'proposer': 'test@swag.com',
                  'circle': ['yolo@swag.com'],
                  'proposal': 'some_proposal'
    }

    post '/create-proposal', request_body.to_json

    expect(TestSupport::Doubles::Mailer.origin).to eq('consensus@devscola.org')
  end

  it 'ignores repeated recipients' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    request_body_with_repeated_mails = {
              'proposer': 'some@zzz.com',
              'circle': ['yolo@swag.com', 'yolo@swag.com', 'some@zzz.com'],
              'proposal': 'some_proposal'
    }

    post '/create-proposal', request_body_with_repeated_mails.to_json

    expect(TestSupport::Doubles::Mailer.delivered_count).to eq(2)
  end


  it 'sends mails to everybody involved' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    request_body = {
              'proposer': 'some@zzz.com',
              'circle': ['yolo@swag.com', 'bbq@wtf.com'],
              'proposal': 'some_proposal'
    }

    post '/create-proposal', request_body.to_json

    expect(TestSupport::Doubles::Mailer.delivered_count).to eq(3)
  end

  it 'uses proposal as Body' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    request_body = {
              'proposer': 'some@zzz.com',
              'circle': ['yolo@swag.com', 'bbq@wtf.com'],
              'proposal': 'some_proposal'
    }

    post '/create-proposal', request_body.to_json

    expect(TestSupport::Doubles::Mailer.last_sent_body).to include('some_proposal')
  end

  context 'uses a template' do
    it 'with beautified involved list' do
      stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
      body = {
          'proposer': 'pepe@correo.org',
          'circle': ['raul@nocucha.es', 'raul@correo.com'],
          'proposal': 'Nuestra proposal es muy buena, porque lo decimos'
        }

        post '/create-proposal', body.to_json
        sent_email = TestSupport::Doubles::Mailer.last_sent_body
        involved_in_template = 'raul@nocucha.es, raul@correo.com'

        expect(sent_email).to include(involved_in_template)
    end

    it 'different for proposer' do
        stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
        body = { 'proposer': 'pepe@correo.org',
                      'circle': ['pepe@correo.org', 'raul@correo.com'],
                      'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

        post '/create-proposal', body.to_json

        total_deliveries = TestSupport::Doubles::Mailer.delivered_count
        first_delivery = TestSupport::Doubles::Mailer.first_sent_body
        second_delivery = TestSupport::Doubles::Mailer.last_sent_body


        expect(total_deliveries).to eq(2)
        expect(first_delivery).to include('Consensus Proposal for proposer')
        expect(second_delivery).to_not include('Consensus Proposal for proposer')
    end
  end

  it 'for involved that includes CTA for consensus and disensus' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    recipient = Fixture::RECIPIENT
    proposal = Proposal.new(id_proposal: Fixture::ID_PROPOSAL, proposer: Fixture::PROPOSER, involved: Fixture::INVOLVED, proposal: Fixture::PROPOSAL, domain_link: Fixture::DOMAIN_LINK, consensus_email: Fixture::CONSENSUS_EMAIL)
    receiver = Notify.select_receiver(recipient, proposal.proposer)

    token_consensus = Enigma.encode("id_proposal=" + proposal.id_proposal + "&user=" + recipient + '&decision=consensus')
    token_disensus = Enigma.encode("id_proposal=" + proposal.id_proposal + "&user=" + recipient + '&decision=disensus')
    consensus_link = proposal.domain_link + token_consensus
    disensus_link =  proposal.domain_link + token_disensus

    Notify.body_constructor(proposal, recipient, receiver)
    body_content = Notify.get_body
    expect(body_content).to include(consensus_link)
    expect(body_content).to include(disensus_link)
  end

end

describe 'Vote endpoint' do

  before(:each) do
    Repository::Votes.clear
    Repository::Proposals.clear
  end

  after(:each) do
    Repository::Votes.clear
    Repository::Proposals.clear
  end

  it 'send a json' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    proposal = Proposal.new(id_proposal: '1', proposer: Fixture::PROPOSER, involved: ['pepe@correo.es'], proposal: "Text of proposal", domain_link: Fixture::DOMAIN_LINK, consensus_email: Fixture::CONSENSUS_EMAIL)
    Repository::Proposals.save(proposal)
    token = Enigma.encode("id_proposal=1&user=pepe@correo.es&decision=disensus")
    body_sended = {
      token: token
    }

    post '/vote-consensus', body_sended.to_json

    have_expected_keys
  end

  it 'checks if user has voted for a proposal yet' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    proposal = Proposal.new(id_proposal: '1', proposer: Fixture::PROPOSER, involved: ['pepe@correo.es'], proposal: Fixture::PROPOSAL, domain_link: Fixture::DOMAIN_LINK, consensus_email: Fixture::CONSENSUS_EMAIL)
    Repository::Proposals.save(proposal)
    token = Enigma.encode("id_proposal=1&user=pepe@correo.es&decision=disensus")
    body_sended = {
      token: token
    }

    post '/vote-consensus', body_sended.to_json
    post '/vote-consensus', body_sended.to_json

    count_consensus = Repository::Votes.consensus_count('1')
    count_disensus = Repository::Votes.disensus_count('1')
    count_votes = count_consensus + count_disensus
    expect(count_votes).to eq(1)
  end

  it 'allows to update votes for the same proposal' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    proposal = Proposal.new(id_proposal: '1', proposer: Fixture::PROPOSER, involved: ['pepe@correo.es'], proposal: Fixture::PROPOSAL, domain_link: Fixture::DOMAIN_LINK, consensus_email: Fixture::CONSENSUS_EMAIL)
    Repository::Proposals.save(proposal)

    token_disensus = Enigma.encode('id_proposal=1&user=pepe@correo.es&decision=disensus')
    body_disensus = {
      token: token_disensus
    }
    post '/vote-consensus', body_disensus.to_json
    retrieve_first_vote = Repository::Votes.retrieve('1', 'pepe@correo.es')
    expect(retrieve_first_vote.decision).to eq('disensus')

    token_consensus = Enigma.encode('id_proposal=1&user=pepe@correo.es&decision=consensus')
    body_consensus = {
      token: token_consensus
    }
    post '/vote-consensus', body_consensus.to_json
    retrieve_second_vote = Repository::Votes.retrieve('1', 'pepe@correo.es')
    expect(retrieve_second_vote.decision).to eq('consensus')

    count_consensus = Repository::Votes.consensus_count('1')
    count_disensus = Repository::Votes.disensus_count('1')
    count_votes = count_consensus + count_disensus
    expect(count_votes).to eq(1)
  end
end

def have_expected_keys
  parsed = last_response.body
  expect(parsed).to include("user")
  expect(parsed).to include("proposer")
  expect(parsed).to include("decision")
  expect(parsed).to include("proposal_text")
end
