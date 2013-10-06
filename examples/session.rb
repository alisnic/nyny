#!ruby -I ../lib -I lib
require 'nyny'

class App < NYNY::App
  use Rack::Session::Cookie, :secret => 'my_secret' #store session in cookies

  before do
    headers 'Content-Type' => 'text/plain'
  end

  get '/' do
    session.merge! params
    "Use ? in URL to write to session
     Eg: /?foo=bar

     Session: #{session.inspect}"
  end
end

App.run! 9000
