module NYNY
  class Request < Rack::Request
  end

  class Response < Rack::Response
    def rewrite str
      @body = []
      write str
    end
  end
end
