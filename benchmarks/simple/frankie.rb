#!ruby -I ../../lib -I lib
require 'frankie'

class App < Frankie::App
  get '/' do
    'Hello World!'
  end
end

App.run!
