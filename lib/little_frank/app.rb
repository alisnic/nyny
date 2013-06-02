module LittleFrank
  class App
    extend ClassLevelApi

    def initialize app=nil
      @app = app
      build_middleware_chain
    end

    def route req
      begin
        handler = self.class.routes
                      .fetch(req.request_method.downcase.to_sym)
                      .fetch(req.path)

        RequestScope.new(self.class.defaults, req).apply_to &handler
      rescue KeyError
        Rack::Response.new '', 404, self.class.defaults[:headers]
      end
    end

    def _call env
      route Rack::Request.new(env)
    end

    def build_middleware_chain
      # #<Mid1> -> #<Mid2> -> ...
      @top = self.class.middlewares.reverse.reduce (self) do |prev, entry|
        klass, args, blk = entry
        klass.new prev, *args, &blk
      end
    end

    def call env
      if @top == self
        _call env
      else
        if not @initialized_chain
          @initialized_chain = true
          @top.call(env)
        else
          @initialized_chain = false
          _call env
        end
      end
    end
  end
end
