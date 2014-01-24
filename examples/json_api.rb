#!ruby -I ../lib -I lib
require 'nyny'
require 'json'

class App < NYNY::App
  before { headers['Content-Type'] = 'application/json' }

  helpers do
    def json data
      data.to_json
    end
  end

  get '/' do
    json({})
  end
end

App.run! 9000
