require 'net/http'
require 'rspec'
require 'json'
require 'rack/test'
require 'mail'

require_relative '../app.rb'
require_relative '../system/notify'
require_relative 'test_support/fixture'
require_relative '../system/proposal'

describe 'Send mail endpoint' do

  include Rack::Test::Methods

  def app
    App
  end

  before(:each) do
    Mail.defaults do
       delivery_method :test
    end
  end

  after(:each) do
    Mail::TestMailer.deliveries.clear
  end

  it 'accepts a json with required parameters' do
    body = { 'proposer': 'proposer@proposer.es',
                  'circle': ['involved@involved.es'],
                  'proposal': 'A proposal'}

    post '/create-proposal', body.to_json

    expect(last_response).to be_ok
  end

  it 'uses the consensus default email as From' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/create-proposal', body.to_json

    sent_email = Mail::TestMailer.deliveries.first
    expect(sent_email.from).to eq(['consensus@devscola.org'])
  end

  it 'ignores repeated recipients' do
    body = { 'proposer': 'pepe@correo.org',
            'circle': ['raul@nocucha.es', 'raul@nocucha.es', 'pepe@correo.org', 'raul@correo.com', 'raul@correo.com'],
            'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/create-proposal', body.to_json

    sent_email = Mail::TestMailer

    expect(sent_email.deliveries[0].to).to eq(['pepe@correo.org'])
    expect(sent_email.deliveries[1].to).to eq(['raul@nocucha.es'])
    expect(sent_email.deliveries[2].to).to eq(['raul@correo.com'])

    expect(sent_email.deliveries.length).to eq(3)
  end

  it 'uses both the involved and the proposer as To with independent deliveries' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/create-proposal', body.to_json

    sent_email = Mail::TestMailer.deliveries[0]
    expect(sent_email.to).to eq(['pepe@correo.org'])
    sent_email = Mail::TestMailer.deliveries[1]
    expect(sent_email.to).to eq(['raul@nocucha.es'])
    sent_email = Mail::TestMailer.deliveries[2]
    expect(sent_email.to).to eq(['raul@correo.com'])
  end

  it 'uses proposal as Body' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/create-proposal', body.to_json
    sent_email = Mail::TestMailer.deliveries.first

    expect(sent_email.body).to include('Nuestra proposal es muy buena, porque lo decimos')
  end

  it 'extracts subject from the proposal as Subject' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/create-proposal', body.to_json
    sent_email = Mail::TestMailer.deliveries.first

    expect(sent_email.subject).to eq('Nuestra proposal es muy buena, porque...')
  end

  context 'uses a template' do
    it 'with beautified involved list' do
      body = { 'proposer': 'pepe@correo.org',
        'circle': ['raul@nocucha.es', 'raul@correo.com'],
        'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

        post '/create-proposal', body.to_json
        sent_email = Mail::TestMailer.deliveries.first
        involved_in_template = 'raul@nocucha.es, raul@correo.com'

        expect(sent_email.body).to include(involved_in_template)
    end

    it 'different for proposer' do
        body = { 'proposer': 'pepe@correo.org',
                      'circle': ['gato@correo.org', 'pepe@correo.org', 'raul@nocucha.es'],
                      'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

        post '/create-proposal', body.to_json

        total_deliveries = Mail::TestMailer.deliveries.length
        first_delivery = Mail::TestMailer.deliveries[0].body
        second_delivery = Mail::TestMailer.deliveries[1].body
        third_delivery = Mail::TestMailer.deliveries[2].body

        expect(total_deliveries).to eq(3)
        expect(first_delivery).to include('Consensus Proposal for proposer')
        expect(second_delivery).to include('Consensus Proposal for circle')
        expect(second_delivery).to include('Consensus Proposal for circle')
    end

    it 'for involved that includes CTA for consensus and disensus' do
      template = Fixture::TEMPLATE_INVOLVED
      recipient = Fixture::RECIPIENT
      proposal = Proposal.new(Fixture::ID_PROPOSAL, Fixture::PROPOSER, Fixture::CIRCLE, Fixture::PROPOSAL, Fixture::DOMAIN_LINK, Fixture::CONSENSUS_EMAIL )

      consensus_link = proposal.domain_link + "id=" + proposal.id_proposal + "&user=" + recipient + '&vote=consensus'
      disensus_link =  proposal.domain_link + "id=" + proposal.id_proposal + "&user=" + recipient + '&vote=disensus'

      Notify.body_constructor(proposal, recipient, template)
      body_content = Notify.get_body
      expect(body_content).to include(consensus_link)
      expect(body_content).to include(disensus_link)
    end

  end
    it 'send a json' do
      body_sended = {
       token: 'id=1&user=pepe@correo.es&vote=disensus'
      }
      post '/vote-consensus', body_sended.to_json
      have_expected_keys
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
end
