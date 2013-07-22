require 'nyny'
require 'rack'
require 'securerandom'

require 'coveralls'
Coveralls.wear!

include NYNY

class Rack::MockRequest
  def trace(uri, opts={})     request("TRACE", uri, opts)     end
  def options(uri, opts={})   request("OPTIONS", uri, opts)   end
end

def extended_modules_for kls
  (class << kls; self end).included_modules
end

def mock_app &blk
  Rack::MockRequest.new frankie_app(&blk).new
end

def frankie_app &blk
  Class.new(App, &blk)
end

def random_url levels=1
  parts = levels.times.map do
    SecureRandom.urlsafe_base64
  end

  "/#{parts.join('/')}"
end

class NullMiddleware
  def initialize app
    @app = app
  end

  def call env
    @app.call env
  end
end

module NullHelper
end
