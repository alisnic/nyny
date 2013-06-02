module LittleFrank
  class RequestScope
    attr_reader :request
    attr_accessor :response

    def initialize defaults, req
      @headers = defaults[:headers].dup
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
      data = instance_eval(&handler).to_s
      response = Rack::Response.new data, @status, @headers
      response.redirect(@redirect) if @redirect
      response
    end
  end
end
