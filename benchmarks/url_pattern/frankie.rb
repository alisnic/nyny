#!ruby -I ../../lib -I lib
require 'frankie'

class App < Frankie::App
  get '/hello/:name' do
    "Hello #{params[:name]}!"
  end
end

App.run!
