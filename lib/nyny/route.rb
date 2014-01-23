require 'journey'

module NYNY
  class Route
    attr_reader :pattern, :handler, :method
    def initialize method, signature, &block
      @pattern = Journey::Path::Pattern.new(signature)
      @handler = Proc.new(&block)
      @method = method.to_s.upcase
    end

    def match? env
      return false unless method == env['REQUEST_METHOD']
      not pattern.match(env['PATH_INFO']).nil?
    end

    def url_params env
      data = pattern.match(env['PATH_INFO'])
      Hash[data.names.zip(data.captures)]
    end
  end
end
