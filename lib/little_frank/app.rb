module LittleFrank
  class App
    HTTP_VERBS = [:delete, :get, :head, :options, :patch, :post, :put, :trace]
    extend ClassMethods

    HTTP_VERBS.each do |method|
      define_singleton_method method do |path, &blk|
        (routes[method] ||= {})[path] = Proc.new &blk
      end
    end

    def route req
      begin
        handler = self.class.routes
                      .fetch(req.request_method.downcase.to_sym)
                      .fetch(req.path)

        RequestScope.new(self.class.defaults, req).apply_to &handler
      rescue KeyError
        [404, self.class.defaults[:headers], [""]]
      end
    end

    def call env
      route Rack::Request.new(env)
    end
  end
end
