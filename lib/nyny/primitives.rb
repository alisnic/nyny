module NYNY
  class Request < Rack::Request
  end

  class Response < Rack::Response
    def rewrite str
      @body   = []
      @length = 0
      header.delete "Content-Type"
      header.delete "Content-Length"
      write str
    end
  end
end
