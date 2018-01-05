require 'rubygems'
require 'sinatra/base'
require 'mail'
require 'sinatra/cross_origin'
require 'json'

require_relative './subject_method'
require_relative './system/service'

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
    communication = Communication.new

    consensus_email = 'consensus@devscola.org'
    circle = params['circle']
    proposer = params['proposer']
    consensus_to = communication.remove_repeated_emails(circle, proposer)
    consensus_to_beautified = consensus_to.to_s.gsub(/[\"\[\]]/,"")
    proposal = params['proposal']
    consensus_subject = create_subject(proposal)

    consensus_body = erb :proposer_email_template, locals: {
      proposer: proposer,
      circle: consensus_to_beautified,
      proposal: proposal
    }

    communication.send_mail(consensus_email, consensus_to, consensus_subject, consensus_body)
  end
end
