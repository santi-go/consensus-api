require 'net/http'
require 'rspec'
require 'json'
require 'rack/test'
require 'mail'

require_relative '../app.rb'
require_relative '../system/notify_involved'


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

    expect(sent_email.deliveries[0].to).to eq(['raul@nocucha.es'])
    expect(sent_email.deliveries[1].to).to eq(['pepe@correo.org'])
    expect(sent_email.deliveries[2].to).to eq(['raul@correo.com'])

    expect(sent_email.deliveries.length).to eq(3)

  end

  it 'uses both the involved and the proposer as To with independent deliveries' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/create-proposal', body.to_json

    sent_email = Mail::TestMailer.deliveries[0]
    expect(sent_email.to).to eq(['raul@nocucha.es'])
    sent_email = Mail::TestMailer.deliveries[1]
    expect(sent_email.to).to eq(['raul@correo.com'])
    sent_email = Mail::TestMailer.deliveries[2]
    expect(sent_email.to).to eq(['pepe@correo.org'])
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
    it 'including a proposer' do
        body = { 'proposer': 'pepe@correo.org',
                      'circle': ['raul@nocucha.es', 'raul@correo.com'],
                      'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

        post '/create-proposal', body.to_json
        sent_email = Mail::TestMailer.deliveries.first

        expect(sent_email.body).to include('pepe@correo.org')
      end

    it 'with beautified involved list' do
      body = { 'proposer': 'pepe@correo.org',
                    'circle': ['raul@nocucha.es', 'raul@correo.com'],
                    'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

      post '/create-proposal', body.to_json
      sent_email = Mail::TestMailer.deliveries.first
      involved_in_template = 'raul@nocucha.es, raul@correo.com, pepe@correo.org'
      expect(sent_email.body).to include(involved_in_template)
    end

    it 'body constructor includes CTA for consensus and disensus' do
      body_data = {
        :proposer => 'pepe@correo.org',
        :consensus_to => ['correo1@domain.es', 'correo2@domain.es', 'pepe@correo.org'],
        :proposal => 'Nuestra proposal es muy buena, porque lo decimos',
        :domain_link => 'http://localhost:8080/proposal',
        :id_proposal => 'proposal_identification',
        :recipient => 'correo1@domain.es'
      }

      consensus_link = body_data[:domain_link] + '/' + body_data[:id_proposal] + '/' + body_data[:recipient] + '/consensus/'
      disensus_link =  body_data[:domain_link] + '/' + body_data[:id_proposal] + '/' + body_data[:recipient] + '/disensus/'

      Notify_involved.body_constructor(body_data)
      body_content = Notify_involved.get_body
      expect(body_content).to include(consensus_link)
      expect(body_content).to include(disensus_link)
    end
    it 'api send a json' do
      body = {
        :email => 'pepe@correo.org',
        :vote => 'disensus',
        :id_proposal => '1'
      }
      post '/vote-consensus', body.to_json
      have_expected_keys
      
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
end
