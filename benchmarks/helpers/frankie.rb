#!ruby -I ../../lib -I lib
require 'frankie'

module Dude
  def da_request_man
    request
  end
end

class App < Frankie::App
  helpers Dude

  get '/' do
    da_request_man
    'Hello World!'
  end
end

App.run!
