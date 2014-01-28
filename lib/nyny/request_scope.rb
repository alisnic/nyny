require 'forwardable'
require 'rack/contrib/cookies'

module NYNY
  class RequestScope
    extend Forwardable

    attr_reader :request, :response
    def_delegators :request, :session, :params
    def_delegators :response, :headers

    def initialize env
      @request  = Request.new(env)
      @request.params.merge! env['nyny.params']
      @response = Response.new [], 200, {'Content-Type' => 'text/html'}
    end

    def cookies
      @cookies ||= Rack::Cookies::CookieJar.new(request.cookies)
    end

    def status code
      response.status = code
    end

    def halt status, headers={}, body=''
      response.status = status
      response.headers.merge! headers
      response.rewrite body
      cookies.finish!(response) if @cookies
      throw :halt, response.finish
    end

    def redirect_to uri, status=302
      halt status, {'Location' => uri}
    end
    alias_method :redirect, :redirect_to

    def apply_to &handler
      response.write instance_eval(&handler)
      cookies.finish!(response) if @cookies
      response.finish
    end
  end
end
