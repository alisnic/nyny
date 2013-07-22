module NYNY
  class Request < Rack::Request
  end

  class Response < Rack::Response
    attr_reader :raw_body

    def initialize body=[], status=200, header={}
      @raw_body = body
      super body.to_s, status, header
    end

    def body= value
      @raw_body = value
      @body = []
      @length = 0

      if value.respond_to? :to_str
        write value.to_str
      elsif value.respond_to?(:each)
        value.each {|part| write part.to_s }
      end
    end
  end
end
