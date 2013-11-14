module NYNY
  class RequestScope
    attr_reader :request, :response

    def self.add_helper_module m
      include m
    end

    DEFAULT_RESPONSE = NYNY::Response.new '', 200, {'Content-Type' => 'text/html'}

    def initialize request
      @request = request
      @response = DEFAULT_RESPONSE.clone
    end

    def params
      request.params
    end

    def headers hash={}
      response.headers.merge! hash
    end

    def session
      request.session
    end

    def cookies
      request.cookies
    end

    def status code
      response.status = code
    end

    def halt status, headers={}, body=''
      response.status = status
      response.headers.merge! headers
      response.body = body
      throw :halt, response
    end

    def redirect_to uri, status=302
      halt status, {'Location' => uri}
    end
    alias_method :redirect, :redirect_to

    def apply_to &handler
      response.body = instance_eval(&handler)
      cookies.each {|k,v| response.set_cookie k,v }
      response
    end
  end
end
