module LittleFrank
  module ClassMethods
    def defaults
      @defaults ||= {
        :headers => {"Content-Type" => "text/html"}
      }
    end

    def routes
      @routes ||= {}
    end

    def content_type type
      defaults[:headers]["Content-Type"] = type
    end
  end
end
