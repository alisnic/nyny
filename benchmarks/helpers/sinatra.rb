#!ruby -I ../../lib -I lib
require 'sinatra'

module Dude
  def da_request_man
    request
  end
end

class App < Sinatra::Base
  helpers Dude

  get '/' do
    da_request_man
    'Hello World!'
  end
end

Rack::Handler::Thin.run App.new, :Port => 9000
