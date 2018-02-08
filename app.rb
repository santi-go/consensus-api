require 'rubygems'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'json'

require_relative './system/notify'
require_relative './system/proposal'

class App < Sinatra::Base

  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  post '/create-proposal' do
    params = JSON.parse(request.body.read)
    id_proposal = 'proposal_identification'

    domain = 'http://localhost:8080/'
    link = 'reunion-consensus.html?'
    domain_link = domain + link
    consensus_email = 'consensus@devscola.org'

    proposal = Proposal.new(id_proposal, params['proposer'], params['circle'], params['proposal'], domain_link, consensus_email)

    Notify.do(proposal)
  end

  options "*" do
    response.headers["Allow"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end

  post '/vote-consensus' do
    params = JSON.parse(request.body.read)
    user = params['user']
    vote = params['vote']
    id_proposal = params['id_proposal']
    generate_json = {
      :user => user,
      :proposer => 'proposer@mail.com',
      :vote => vote,
      :total_consensus => 3,
      :total_disensus => 2,
      :proposal_text => 'Lorem ipsum'
    }.to_json
    generate_json
  end

end
