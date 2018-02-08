require 'json'
require 'rack/test'

require_relative '../app.rb'
require_relative 'test_support/fixture'
require_relative 'test_support/doubles/mailer'

describe 'Send mail endpoint' do

  include Rack::Test::Methods

  def app
    App
  end

  before(:each) do
    TestSupport::Doubles::Mailer.clear
  end

  after(:each) do
    TestSupport::Doubles::Mailer.clear
  end

  it 'accepts a json with required parameters' do
    body = {
            'proposer' => 'proposer@proposer.es',
            'circle' => ['involved@involved.es'],
            'proposal' => 'some_proposal'
    }

    post '/create-proposal', body.to_json

    expect(last_response).to be_ok
  end

  it 'uses the consensus default email as sender email' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    request_body = {
                  'proposer' => 'test@swag.com',
                  'circle' => ['yolo@swag.com'],
                  'proposal' => 'some_proposal'
    }

    post '/create-proposal', request_body.to_json

    expect(TestSupport::Doubles::Mailer.origin).to eq('consensus@devscola.org')
  end

  it 'ignores repeated recipients' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    request_body_with_repeated_mails = {
              'proposer' => 'some@zzz.com',
              'circle' => ['yolo@swag.com', 'yolo@swag.com', 'some@zzz.com'],
              'proposal' => 'some_proposal'
    }

    post '/create-proposal', request_body_with_repeated_mails.to_json

    expect(TestSupport::Doubles::Mailer.delivered_count).to eq(2)
  end


  it 'sends mails to everybody involved' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    request_body = {
              'proposer' => 'some@zzz.com',
              'circle' => ['yolo@swag.com', 'bbq@wtf.com'],
              'proposal' => 'some_proposal'
    }

    post '/create-proposal', request_body.to_json

    expect(TestSupport::Doubles::Mailer.delivered_count).to eq(3)
  end

  it 'uses proposal as Body' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    request_body = {
              'proposer' => 'some@zzz.com',
              'circle' => ['yolo@swag.com', 'bbq@wtf.com'],
              'proposal' => 'some_proposal'
    }

    post '/create-proposal', request_body.to_json

    expect(TestSupport::Doubles::Mailer.last_sent_body).to include('some_proposal')
  end

  xcontext 'uses a template' do
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
