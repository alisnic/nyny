require 'active_support/hash_with_indifferent_access'

module NYNY
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
