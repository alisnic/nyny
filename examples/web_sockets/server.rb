#!ruby -I ../../lib -I lib
require 'nyny'
require 'faye/websocket'

#
# Open localhost:9000/public/index.html in the browser
#

Faye::WebSocket.load_adapter('thin')

class WebSockets
  def initialize app=nil, opts={}, &blk
    @app = app
    @path = opts.fetch :path, '/'
    @blk = blk
  end

  def call env
    return @app.call(env) unless env['PATH_INFO'] == @path

    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)

      if @blk
        Proc.new(&@blk).call ws
      else
        handle ws
      end

      ws.rack_response
    else
      @app.call(env)
    end
  end

  def handle ws
  end
end

class App < NYNY::App
  #Serve static assets from public folder
  use Rack::Static, :urls => ["/public"]

  use WebSockets, :path => '/websocket' do |ws|
    ws.on :message do |event|
      ws.send(event.data)
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason]
      ws = nil
    end
  end

  get '/nyny' do
    'yep, you can still use nyny'
  end
end

App.run! 9000
