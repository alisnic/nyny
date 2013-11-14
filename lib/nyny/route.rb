module NYNY
  class Route

    class RegexpMatcher
      NAME_PATTERN = /:(\S+)/

      attr_reader :pattern

      def initialize signature
        @pattern = pattern_for(signature).freeze
      end

      def pattern_for signature
        signature = signature.start_with?('/') ? signature : "/#{signature}"

        groups = signature.split('/').map do |part|
          next part if part.empty?
          next part unless part.start_with? ':'
          name = NAME_PATTERN.match(part)[1]
          %Q{(?<#{name}>\\S+)}
        end.select {|s| !s.empty? }.join('\/')

        %r(^\/#{groups}$)
      end

      def match? path
        not pattern.match(path).nil?
      end

      def url_params env
        data = pattern.match(env[NYNY::PATH_INFO])
        Hash[data.names.map {|n| [n.to_sym, URI.unescape(data[n])]}]
      end
    end

    class StringMatcher
      attr_reader :pattern

      def initialize signature
        @pattern = signature.freeze
      end

      def match? path
        pattern == path
      end

      def url_params env
        {}
      end
    end

    attr_reader :matcher, :handler, :method

    def initialize method, signature, &block
      @matcher = matcher_for(signature)
      @handler = Proc.new(&block)
      @method  = method.to_s.upcase
    end

    def matcher_for signature
      matcher = signature.is_a?(Regexp) || signature.include?(':') ? RegexpMatcher : StringMatcher
      matcher.new signature
    end

    def match? env
      matcher.match? env[NYNY::PATH_INFO]
    end

    def url_params env
      matcher.url_params env
    end
  end
end
