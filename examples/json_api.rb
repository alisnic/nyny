#!ruby -I ../lib -I lib
require 'nyny'
require 'json'

#
# Every response of this app will be automatically converted to json
#
class App < NYNY::App
  before { headers['Content-Type'] = 'application/json' }

  helpers do
    def json data
      data.to_json
    end
  end

  get '/' do
    raise 'chlen'
    json :some => [:json, :mate!]
  end
end

App.run! 9000
