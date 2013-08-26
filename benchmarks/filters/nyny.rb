#!ruby -I ../../lib -I lib
require 'nyny'

class App < NYNY::App
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

App.run!
