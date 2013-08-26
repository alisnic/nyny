#!ruby -I ../lib -I lib
require 'nyny'
require 'json'

#
# Every response of this app will be automatically converted to json
#
class App < NYNY::App
  before { headers 'Content-Type' => 'application/json' }

  after do
    body = response.raw_body
    response.body = body.to_json if body.respond_to? :to_json
  end

  get '/' do
    {:some => [:json, :mate!]}
  end
end

App.run! 9000
