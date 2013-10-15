module NYNY
  class Route
    NAME_PATTERN = /:(\S+)/

    attr_reader :pattern, :handler, :method
    def initialize method, signature, &block
      @pattern = pattern_for signature
      @handler = Proc.new(&block)
      @method = method.to_s.upcase
    end

    def pattern_for signature
      return signature if signature.is_a? Regexp
      build_regex(signature.start_with?('/') ? signature : "/#{signature}")
    end

    def build_regex signature
      return %r(^#{signature}$) unless signature.include?(':')

      groups = signature.split('/').map do |part|
        next part if part.empty?
        next part unless part.start_with? ':'
        name = NAME_PATTERN.match(part)[1]
        %Q{(?<#{name}>\\S+)}
      end.select {|s| !s.empty? }.join('\/')

      %r(^\/#{groups}$)
    end

    def match? env
      return false unless method == env['REQUEST_METHOD']
      not pattern.match(env['PATH_INFO']).nil?
    end

    def url_params env
      data = pattern.match(env['PATH_INFO'])
      Hash[data.names.map {|n| [n.to_sym, URI.unescape(data[n])]}]
    end
  end
end
