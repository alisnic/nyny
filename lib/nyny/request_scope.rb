module NYNY
  class RequestScope
    attr_reader :request, :response
    HaltError = Class.new(StandardError)

    def self.add_helper_module m
      include m
    end

    def initialize request
      @headers = {'Content-Type' => 'text/html'}
      @status = 200
      @request = request
    end

    def params
      request.params
    end

    def headers hash={}
      @headers.merge! hash
    end

    def session
      request.session
    end

    def cookies
      request.cookies
    end

    def status code
      @status = code
    end

    def halt status, headers={}, body=''
      throw :halt, Response.new(body, status, @headers.merge(headers))
    end

    def redirect_to uri, status=302
      halt status, {'Location' => uri}
    end
    alias_method :redirect, :redirect_to

    def apply_to &handler
      @response = Response.new instance_eval(&handler), @status, @headers
      cookies.each {|k,v| @response.set_cookie k,v }
      @response
    end
  end
end
