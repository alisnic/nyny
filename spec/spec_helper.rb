require 'frankie'
require 'rack'
include Frankie

class Rack::MockRequest
  def trace(uri, opts={})   request("TRACE", uri, opts)   end
end

def extended_modules_for kls
  (class << kls; self end).included_modules
end

def mock_app &blk
  Rack::MockRequest.new Class.new(App, &blk).new
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
