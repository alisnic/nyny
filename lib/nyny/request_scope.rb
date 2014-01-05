require 'forwardable'

module NYNY
  class RequestScope
    extend Forwardable

    def self.add_helper_module m
      include m
    end

    attr_reader :request, :response
    def_delegators :request, :params, :session

    def initialize request
      @request = request
      @response = Response.new '', 200, {'Content-Type' => 'text/html'}
    end

    def cookies
      @cookies ||= Rack::Cookies::CookieJar.new(request.cookies)
    end

    def headers hash={}
      response.headers.merge! hash
    end

    def status code
      response.status = code
    end

    def halt status, headers={}, body=''
      response.status = status
      response.headers.merge! headers
      response.body = body
      throw :halt, response.finish
    end

    def redirect_to uri, status=302
      halt status, {'Location' => uri}
    end
    alias_method :redirect, :redirect_to

    def apply_to &handler
      response.body = instance_eval(&handler)
      cookies.finish!(response)
      response.finish
    end
  end
end
