#!ruby -I ../../lib -I lib
require 'frankie'
require 'json'
require 'faye/websocket'

#
# Open localhost:9000/public/index.html in the browser
#

Faye::WebSocket.load_adapter('thin')

class Sockets
  def initialize app=nil, opts={}
    @app = app
    @path = opts.fetch :path, '/'
  end

  def call env
    return @app.call(env) unless env['PATH_INFO'] == @path

    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)
      handle ws
      ws.rack_response
    else
      @app.call(env)
    end
  end

  def handle ws
    ws.on :message do |event|
      ws.send(event.data)
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason]
      ws = nil
    end
  end
end

class App < Frankie::App
  #Serve static assets from public folder
  use Rack::Static, :urls => ["/public"]
  use Sockets, :path => '/websocket'

  get '/frankie' do
    'yep, you can still use frankie'
  end
end

App.run! 9000
