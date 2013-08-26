#!ruby -I ../../lib -I lib
require 'nyny'

class App < NYNY::App
  get '/hello/:name' do
    "Hello #{params[:name]}!"
  end
end

App.run!
