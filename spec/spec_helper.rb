require 'rack'
require 'securerandom'
ENV['RACK_ENV'] = 'test'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start do
    add_filter "spec"
  end
end

require 'nyny'
include NYNY

class Rack::MockRequest
  def trace(uri, opts={})     request("TRACE", uri, opts)     end
  def options(uri, opts={})   request("OPTIONS", uri, opts)   end
end

def template name
  File.join(File.dirname(__FILE__), 'views', name)
end

def extended_modules_for kls
  (class << kls; self end).included_modules
end

def mock_app &blk
  Rack::MockRequest.new mock_app_class(&blk).new
end

def mock_app_class &blk
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
