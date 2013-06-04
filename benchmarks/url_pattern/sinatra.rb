#!ruby -I ../../lib -I lib
require 'sinatra'

class App < Sinatra::Base
  get '/hello/:name' do
    "Hello #{params[:name]}!"
  end
end
