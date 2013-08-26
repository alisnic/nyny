module NYNY
  class RouteSignature
    NAME_PATTERN = /:(\S+)/

    attr_reader :pattern
    def initialize signature
      @pattern = pattern_for signature
    end

    def pattern_for string
      return string if string.is_a? Regexp
      return string unless string.include? ':'

      signature = string.start_with?('/') ? string : "/#{string}"
      build_regex signature
    end

    def build_regex signature
      groups = signature.split('/').map do |part|
        next part if part.empty?
        next part unless part.start_with? ':'
        name = NAME_PATTERN.match(part)[1]
        %Q{(?<#{name}>\\S+)}
      end.select {|s| !s.empty? }.join('\/')

      %r(\/#{groups})
    end

    def match path
      return (pattern == path ? {} : nil) if pattern.is_a?(String)
      data = pattern.match path

      if data
        if pattern.respond_to? :names
          Hash[data.names.map {|n| [n.to_sym, URI.unescape(data[n])]}]
        else
          {}
        end
      else
        nil
      end
    end
  end
end
