require 'frankie'
require 'rack'
include Frankie

def extended_modules_for kls
  (class << kls; self end).included_modules
end

def mock_request method, url, kls=App
  kls.new.call Rack::MockRequest.env_for(url, :method => method)
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
