require 'rubygems'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'json'

require_relative './system/notify_involved'

class App < Sinatra::Base

  post '/create-proposal' do
    params = JSON.parse(request.body.read)
    involved = params['circle']
    proposer = params['proposer']
    proposal = params['proposal']

    Notify_involved.do(involved, proposal, proposer)
  end
end
