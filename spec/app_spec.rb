require 'net/http'
require 'rspec'
require 'json'
require 'rack/test'
require 'mail'

require_relative '../app.rb'
require_relative '../subject_method.rb'

describe 'Email' do
  it 'subject has first six words of the proposal' do
    proposal = "En mi opinion deberiamos de crear una funcion que determine el uso del mail"

    subject = create_subject(proposal)

    expect(subject).to eq("En mi opinion deberiamos de crear...")
  end

  it 'subject finished when the sentence finds a dot, <br>, or </p> tag and has a maximum of six words' do
    proposal = "La propuesta esta creada. Consiste en esto."
    proposal1 = "La propuesta esta creada<br>"
    proposal2 = "<p>propuesta</p><p></p><p>con br y p<br> Consiste en esto<p>"

    expect(create_subject(proposal)).to eq("La propuesta esta creada.")
    expect(create_subject(proposal1)).to eq("La propuesta esta creada...")
    expect(create_subject(proposal2)).to eq("propuesta...")
  end
end

describe 'Send mail' do

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

  it 'accepts a json' do
    body = { 'proposer': '',
                  'circle': ['haha'],
                  'proposal': ''}

    post '/send-mail', body.to_json

    expect(last_response).to be_ok
  end

  it 'uses the consensus default email as From' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/send-mail', body.to_json
    sent_email = Mail::TestMailer.deliveries.first
    expect(sent_email.from).to eq(['consensus@devscola.org'])
  end

  it 'uses both the circle and the proposer as To' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/send-mail', body.to_json
    sent_email = Mail::TestMailer.deliveries.first
    expect(sent_email.to).to eq(['raul@nocucha.es', 'raul@correo.com', 'pepe@correo.org'])
  end

  it 'uses proposal as Body' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/send-mail', body.to_json
    sent_email = Mail::TestMailer.deliveries.first
    expect(sent_email.body).to include('Nuestra proposal es muy buena, porque lo decimos')
  end

  it 'extracts subject from the proposal as Subject' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/send-mail', body.to_json
    sent_email = Mail::TestMailer.deliveries.first
    expect(sent_email.subject).to eq('Nuestra proposal es muy buena, porque...')
  end

    it 'uses a template' do
      body = { 'proposer': 'pepe@correo.org',
                    'circle': ['raul@nocucha.es', 'raul@correo.com'],
                    'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

      post '/send-mail', body.to_json
      sent_email = Mail::TestMailer.deliveries.first

      expect(sent_email.body).to include('pepe@correo.org')
    end
end
