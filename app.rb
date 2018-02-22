require 'rubygems'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'json'
require 'base64'

require_relative './system/notify'
require_relative './system/models/proposal'
require_relative './system/models/vote'
require_relative './system/json_validator'
require_relative 'initializers/configure_mail_gem'
require_relative './system/repositories/repository'
require_relative './system/actions/vote'
require_relative './system/actions/create_proposal'

class App < Sinatra::Base

  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  post '/create-proposal' do
    params = JSON.parse(request.body.read)
    return status 422 if !(JSONValidator.validate_create_proposal?(params))
    Actions::CreateProposal.do(params)
  end

  post '/vote-consensus' do
    params = JSON.parse(request.body.read)
    response_to_invited = Actions::Votation.do(params)
    response_to_invited
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
    token = token.split('=')
    token = token[1]
    decode_list = Base64.decode64(token)
    p decode_list

    array = token.split('&')
    array_params = []
    array.each {|element| array_params << element.split('=')}
    hash = array_params.to_h

    user = hash['user']
    vote = hash['vote']
    id_proposal = hash['id_proposal']
    retrieved_proposal = Repository::Proposals.retrieve(id_proposal)
    vote = Vote.new(id_proposal: id_proposal,
                            user: user,
                            vote: vote)
    Repository::Votes.check_vote(vote)

    generated_json = {
      :user => user,
      :proposer => retrieved_proposal.proposer,
      :vote => vote.vote,
      :proposal_text => retrieved_proposal.proposal,
      :id_proposal => id_proposal
    }.to_json
    generated_json
  end

  post '/votation-state' do
    Notify.votation_state
  end
end
