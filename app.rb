require 'rubygems'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'json'

require_relative './system/notify_involved'

class App < Sinatra::Base

  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  post '/create-proposal' do
    params = JSON.parse(request.body.read)
    proposer = params['proposer']
    involved = params['circle']
    proposal = params['proposal']
    domain_link = 'http://localhost:8080/reunion-consensus.html?'
    id_proposal = 'proposal_identification'
    Notify_involved.do(proposer, involved, proposal, domain_link, id_proposal)

  end

  options "*" do
    response.headers["Allow"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end

  post '/vote-consensus' do
    params = JSON.parse(request.body.read)
    email = params['email']
    vote = params['vote']
    id_proposal = params['id_proposal']
    generate_json = {
      :user => email,
      :proposer => 'proposer@mail.com',
      :vote => vote,
      :total_consensus => 3,
      :total_disensus => 2,
      :proposal_text => 'Lorem ipsum'
    }.to_json
    generate_json
  end

end
