require 'rubygems'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'json'

require_relative './system/notify'
require_relative './system/models/proposal'
require_relative './system/models/vote'
require_relative './system/json_validator'
require_relative 'initializers/configure_mail_gem'
require_relative './system/repositories/repository'
require_relative './system/actions/vote_action'
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
    response_to_invited = Actions::VoteAction.do(params)
    response_to_invited
  end

  options "*" do
    response.headers["Allow"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end
end
