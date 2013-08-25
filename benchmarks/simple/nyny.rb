#!ruby -I ../../lib -I lib
require 'nyny'

class App < NYNY::App
  get '/' do
    'Hello World!'
  end
end

App.run!
