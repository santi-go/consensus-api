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
    involved = params['circle']
    proposer = params['proposer']
    proposal = params['proposal']

    Notify_involved.do(involved, proposal, proposer)
  end

  options "*" do
    response.headers["Allow"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end
end
