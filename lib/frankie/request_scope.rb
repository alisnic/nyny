module Frankie
  class RequestScope
    attr_reader :request, :app, :response

    def self.add_helper_module m
      include m
    end

    def initialize app, req
      @app = app
      @headers = {}
      @status = 200
      @request = req
    end

    def params
      request.params
    end

    def headers hash
      @headers.merge! hash
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
      @response = Rack::Response.new data, @status, @headers
      @response.redirect(@redirect) if @redirect

      app.class.after_hooks.each {|h| instance_eval &h }
      response
    end
  end
end
