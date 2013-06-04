module Frankie
  class RequestScope
    attr_reader :request, :app, :response, :cookies

    def self.add_helper_module m
      include m
    end

    def initialize app, req
      @app = app
      @headers = {'Content-Type' => 'text/html'}
      @status = 200
      @request = req
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

    def redirect_to path
      @redirect = path
    end

    def apply_to &handler
      app.class.before_hooks.each {|h| instance_eval &h }

      data = instance_eval(&handler).to_s
      @response = Response.new data, @status, @headers
      cookies.each {|k,v| @response.set_cookie k,v }
      @response.redirect(@redirect) if @redirect

      app.class.after_hooks.each {|h| instance_eval &h }
      @response.finish
      @response
    end
  end
end
