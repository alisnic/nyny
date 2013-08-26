#!ruby -I ../../lib -I lib
require 'nyny'

module Dude
  def da_request_man
    request
  end
end

class App < NYNY::App
  helpers Dude

  get '/' do
    da_request_man
    'Hello World!'
  end
end

App.run!
