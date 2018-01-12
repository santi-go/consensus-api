require 'rubygems'
require 'sinatra/base'
require 'mail'
require 'sinatra/cross_origin'
require 'json'

require_relative './system/email_sender'
require_relative './system/notify_involved'

class App < Sinatra::Base

  set :bind, '0.0.0.0'
  configure do
    enable :cross_origin
  end

  before do
     response.headers['Access-Control-Allow-Origin'] = '*'
  end

  post '/send-mail' do

    params = JSON.parse(request.body.read)
    consensus_email = 'consensus@devscola.org'
    involved = params['involved']
    proposer = params['proposer']
    proposal = params['proposal']

    consensus_to = remove_repeated_emails(involved, proposer)
    consensus_subject = create_subject(proposal)
    consensus_body = Notify_involved.do(consensus_to, proposal, proposer)

    communication = Communication.new
    communication.send_mail(consensus_email, consensus_to, consensus_subject, consensus_body)
  end
end
