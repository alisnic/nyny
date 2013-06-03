#!ruby -I ../../lib -I lib
require 'frankie'

class App < Frankie::App
  get '/hello/:name' do
    "Hello #{params[:name]}!"
  end
end

Rack::Handler::Thin.run App.new, :Port => 9000
