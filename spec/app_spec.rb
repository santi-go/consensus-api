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
    plain_proposal = "La propuesta esta creada. Consiste en esto."
    proposal_with_break_line = "La propuesta esta creada<br>"
    proposal_html = "<p>propuesta</p><p></p><p>con br y p<br> Consiste en esto<p>"

    expect(create_subject(plain_proposal)).to eq("La propuesta esta creada.")
    expect(create_subject(proposal_with_break_line)).to eq("La propuesta esta creada...")
    expect(create_subject(proposal_html)).to eq("propuesta...")
  end

  it 'subject started with a <br> results in error' do
    proposal_with_initial_br = "        <br>     <br><br> <br><br><br><br><br> propuesta<p></p><p>con br y p<br> Consiste en esto<p>"

    expect(create_subject(proposal_with_initial_br)).to eq("propuesta...")
  end
end

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
                  'circle': ['circle@circle.es'],
                  'proposal': 'A proposal'}

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

  it 'ignores repeated recipients' do
    body = { 'proposer': 'pepe@correo.org',
            'circle': ['raul@nocucha.es', 'raul@nocucha.es', 'pepe@correo.org', 'raul@correo.com', 'raul@correo.com'],
            'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/send-mail', body.to_json

    sent_email = Mail::TestMailer

    expect(sent_email.deliveries[0].to).to eq(['raul@nocucha.es'])
    expect(sent_email.deliveries[1].to).to eq(['pepe@correo.org'])
    expect(sent_email.deliveries[2].to).to eq(['raul@correo.com'])

    expect(sent_email.deliveries.length).to eq(3)

  end

  it 'uses both the circle and the proposer as To with independent deliveries' do
    body = { 'proposer': 'pepe@correo.org',
                  'circle': ['raul@nocucha.es', 'raul@correo.com'],
                  'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

    post '/send-mail', body.to_json

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

  context 'uses a template' do
    it 'including a proposer' do
        body = { 'proposer': 'pepe@correo.org',
                      'circle': ['raul@nocucha.es', 'raul@correo.com'],
                      'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

        post '/send-mail', body.to_json
        sent_email = Mail::TestMailer.deliveries.first

        expect(sent_email.body).to include('pepe@correo.org')
      end

    it 'with beautified circle list' do
      body = { 'proposer': 'pepe@correo.org',
                    'circle': ['raul@nocucha.es', 'raul@correo.com'],
                    'proposal': 'Nuestra proposal es muy buena, porque lo decimos'}

      post '/send-mail', body.to_json
      sent_email = Mail::TestMailer.deliveries.first
      circle_in_template = 'raul@nocucha.es, raul@correo.com, pepe@correo.org'
      expect(sent_email.body).to include(circle_in_template)
    end
  end
end
