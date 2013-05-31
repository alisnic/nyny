module LittleFrank
  class RequestScope
    attr_reader :request
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

    def apply_to &handler
      response = instance_eval(&handler).to_s
      headers({'Content-Length' => response.size.to_s})
      [@status, @headers, [response]]
    end
  end
end
