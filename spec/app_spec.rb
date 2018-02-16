require 'json'
require 'rack/test'

require_relative '../app.rb'
require_relative 'test_support/fixture'
require_relative 'test_support/doubles/mailer'

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
    template = Fixture::TEMPLATE_INVOLVED
    recipient = Fixture::RECIPIENT
    proposal = Proposal.new(id_proposal: Fixture::ID_PROPOSAL, proposer: Fixture::PROPOSER, involved: Fixture::INVOLVED, proposal: Fixture::PROPOSAL, domain_link: Fixture::DOMAIN_LINK, consensus_email: Fixture::CONSENSUS_EMAIL)

    consensus_link = proposal.domain_link + "id=" + proposal.id_proposal + "&user=" + recipient + '&vote=consensus'
    disensus_link =  proposal.domain_link + "id=" + proposal.id_proposal + "&user=" + recipient + '&vote=disensus'

    Notify.body_constructor(proposal, recipient, template)
    body_content = Notify.get_body
    expect(body_content).to include(consensus_link)
    expect(body_content).to include(disensus_link)
  end

end

describe 'Vote endpoint'do

  before(:each) do
    Repository::Votes.clear
  end

  after(:each) do
    Repository::Votes.clear
  end

  it 'send a json' do
    body_sended = {
      token: 'id=1&user=pepe@correo.es&vote=disensus'
    }
    post '/vote-consensus', body_sended.to_json
    have_expected_keys
  end

  it 'checks if user has voted for a proposal yet' do
    body_sended = {
      token: 'id=1&user=pepe@correo.es&vote=disensus'
    }
    post '/vote-consensus', body_sended.to_json
    post '/vote-consensus', body_sended.to_json

    expect(Repository::Votes.vote_count).to eq(1)
  end
end

describe 'Votation state endpoint' do
  it 'sends an email with votation state' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    proposer = 'pepe@correo.org'
    involved = 'helen@gmail.es, zero@gmail.com'
    last_voter = 'zero@gmail.com'
    total_consensus = '90'
    total_disensus = '80'
    proposal = 'Lorem Ipsum'

    post '/votation-state'

    expect(TestSupport::Doubles::Mailer.last_sent_body).to include(proposer)
    expect(TestSupport::Doubles::Mailer.last_sent_body).to include(involved)
    expect(TestSupport::Doubles::Mailer.last_sent_body).to include(last_voter)
    expect(TestSupport::Doubles::Mailer.last_sent_body).to include(total_consensus)
    expect(TestSupport::Doubles::Mailer.last_sent_body).to include(total_disensus)
    expect(TestSupport::Doubles::Mailer.last_sent_body).to include(proposal)
  end
end


def have_expected_keys
  parsed = JSON.parse(last_response.body)
  expect(parsed).to have_key("user")
  expect(parsed).to have_key("proposer")
  expect(parsed).to have_key("vote")
  expect(parsed).to have_key("total_consensus")
  expect(parsed).to have_key("total_disensus")
  expect(parsed).to have_key("proposal_text")
end
