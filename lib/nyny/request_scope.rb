module NYNY
  class RequestScope
    attr_reader :request, :response

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
      @halt_response = Response.new body, status, @headers.merge(headers)
    end

    def redirect_to path
      @redirect = path
    end

    def apply_to &handler
      @response = @halt_response || begin
        Response.new instance_eval(&handler), @status, @headers
      end

      cookies.each {|k,v| @response.set_cookie k,v }
      @response.redirect(@redirect) if @redirect
      @response.finish
      @response
    end
  end
end
