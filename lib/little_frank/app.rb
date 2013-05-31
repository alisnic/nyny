module LittleFrank
  class App
    extend ClassMethods

    [:get, :post].each do |method|
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
        [404, {"Content-Type" => "text/html"}, [""]]
      end
    end

    def call env
      route Rack::Request.new(env)
    end
  end
end
