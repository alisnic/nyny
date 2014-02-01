require 'active_support/hash_with_indifferent_access'
require 'pathname'

module NYNY
  class EnvString < String
    [:production, :development, :test].each do |env|
      define_method "#{env}?" do
        self == env.to_s
      end
    end
  end

  def self.root
    @root ||= Pathname.pwd
  end

  def self.env
    @env ||= EnvString.new(ENV['RACK_ENV'] || 'development')
  end

  class Request < Rack::Request
    def params
      @params ||= ActiveSupport::HashWithIndifferentAccess.new(super)
    end
  end

  class Response < Rack::Response
    def rewrite str
      @body   = []
      @length = 0
      header.delete "Content-Type"
      header.delete "Content-Length"
      write str
    end
    alias_method :body=, :rewrite
  end
end
