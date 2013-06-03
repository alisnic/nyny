#!ruby -I ../../lib -I lib
require 'frankie'

class App < Frankie::App
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
