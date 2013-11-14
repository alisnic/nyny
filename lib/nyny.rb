require 'uri'
require 'rack'

require 'nyny/version'
require 'nyny/primitives'
require 'nyny/request_scope'
require 'nyny/route'
require 'nyny/middleware_chain'
require 'nyny/app'
require 'nyny/router'


# Register core extensions
require 'nyny/core-ext/runner'

module NYNY
  App.register NYNY::Runner

  REQUEST_METHOD = 'REQUEST_METHOD'.freeze
  PATH_INFO      = 'PATH_INFO'.freeze

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
