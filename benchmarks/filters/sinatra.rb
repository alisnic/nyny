#!ruby -I ../../lib -I lib
require 'sinatra'

class App < Sinatra::Base
  before do
    request
  end

  after do
    response
  end

  get '/' do
    'Hello World!'
  end
end

Rack::Handler::Thin.run App.new, :Port => 9000
