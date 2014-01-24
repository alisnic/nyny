require 'uri'
require 'rack'
require 'journey'

require 'nyny/version'
require 'nyny/primitives'
require 'nyny/request_scope'
require 'nyny/router'
require 'nyny/app'
require 'nyny/core-ext/runner'
require 'nyny/core-ext/templates'

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

  App.register NYNY::Runner
  App.register NYNY::Templates
end

