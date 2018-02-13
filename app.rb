require 'rubygems'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'json'

require_relative './system/notify'
require_relative './system/proposals/proposal'
require_relative './system/json_validator'
require_relative 'initializers/configure_mail_gem'
require_relative './system/proposals/repository'

class App < Sinatra::Base

  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  post '/create-proposal' do
    params = JSON.parse(request.body.read)
    domain = 'http://localhost:8080/'
    link = 'reunion-consensus.html?'
    domain_link = domain + link
    consensus_email = 'consensus@devscola.org'
    proposal = Proposal.new(id_proposal=nil, params['proposer'], params['circle'], params['proposal'], domain_link, consensus_email)
    Proposals::Repository.save(proposal)

    if (JSONValidator.validate_create_proposal?(params))
      Notify.do(proposal)
    else
      status 422
    end
  end

  options "*" do
    response.headers["Allow"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end

  post '/vote-consensus' do
    params = JSON.parse(request.body.read)
    token = params['token']
    array = token.split('&')
    array_params = []
    array.each {|element| array_params << element.split('=')}
    hash = array_params.to_h

    user = hash['user']
    vote = hash['vote']
    id_proposal = hash['id_proposal']

    generated_json = {
      :user => user,
      :proposer => 'proposer@mail.com',
      :vote => vote,
      :total_consensus => 3,
      :total_disensus => 2,
      :proposal_text => 'Lorem ipsum'
    }.to_json
    generated_json

  end

  post '/votation-state' do
    Notify.votation_state
  end
end
