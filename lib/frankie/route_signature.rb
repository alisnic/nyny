module Frankie
  class RouteSignature
    NAME_PATTERN = /:(\S+)/
    attr_reader :pattern
    def initialize string
      @pattern = pattern_for string.dup
    end

    def pattern_for string
      return string unless string.include? ':'
      string = "/#{string}" unless string.start_with? '/'
      parts = string.split '/'

      groups = parts.map do |part|
        next part if part.empty?
        next part unless part.start_with? ':'
        name = NAME_PATTERN.match(part)[1]
        %Q{(?<#{name}>\\S+)}
      end.select {|s| !s.empty? }

      %r(\/#{groups.join('\/')})
    end

    def match path
      data = pattern.match path

      if data
        if pattern.respond_to? :names
          Hash[data.names.map {|n| [n.to_sym, URI.unescape(data[n])]}]
        else
          {}
        end
      else
        false
      end
    end
  end
end
