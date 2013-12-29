require 'uri'
require 'rack'

require 'nyny/version'
require 'nyny/primitives'
require 'nyny/request_scope'
require 'nyny/route'
require 'nyny/app'
require 'nyny/router'

# Register core extensions
require 'nyny/core-ext/runner'
require 'nyny/core-ext/templates'
require 'nyny/core-ext/assets'

module NYNY
  class EnvString < String
    [:production, :development, :test].each do |env|
      define_method "#{env}?" do
        self == env.to_s
      end
    end
  end

  def self.root
    Dir.pwd
  end

  def self.env
    @env ||= EnvString.new(ENV['RACK_ENV'] || 'development')
  end
end

NYNY::App.register NYNY::Runner
NYNY::App.register NYNY::Templates
NYNY::App.register NYNY::Assets

