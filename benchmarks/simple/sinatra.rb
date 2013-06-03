#!ruby -I ../../lib -I lib
require 'sinatra'

class App < Sinatra::Base
  get '/' do
    'Hello World!'
  end
end

Rack::Handler::Thin.run App.new, :Port => 9000
