require 'rubygems'
require 'sinatra/base'
require 'mail'
require 'sinatra/cross_origin'
require 'json'
require 'liquid'

require_relative './system/email_fields'
require_relative './system/email_sender'

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
    circle = params['circle']
    proposer = params['proposer']
    proposal = params['proposal']

    consensus_to = remove_repeated_emails(circle, proposer)
    consensus_to_beautified = consensus_to.to_s.gsub(/[\"\[\]]/,"")
    consensus_subject = create_subject(proposal)

    template = Liquid::Template.parse(File.read("./templates/proposer_email.liquid"))
    consensus_body = template.render(
      'proposer' => proposer,
      'circle' => consensus_to_beautified,
      'proposal' => proposal
    )

    communication = Communication.new
    communication.send_mail(consensus_email, consensus_to, consensus_subject, consensus_body)
  end
end
