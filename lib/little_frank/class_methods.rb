module LittleFrank
  module ClassMethods
    HTTP_VERBS = [:delete, :get, :head, :options, :patch, :post, :put,
                  :trace]

    HTTP_VERBS.each do |method|
      define_method method do |path, &blk|
        (routes[method] ||= {})[path] = Proc.new &blk
      end
    end

    def middlewares
      @middlewares ||= []
    end

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

    def use middleware, *args, &block
      middlewares << [middleware, args, block]
    end
  end
end
