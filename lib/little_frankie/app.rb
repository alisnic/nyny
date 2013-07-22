module LittleFrankie
  class App
    extend ClassLevelApi

    RouteNotFoundError = Class.new StandardError

    def initialize app=nil
      @app = app || lambda {|env| Response.new '', 404 }
      build_middleware_chain
    end

    def build_middleware_chain
      @top = self.class.middlewares.reverse.reduce (self) do |prev, entry|
        klass, args, blk = entry
        klass.new prev, *args, &blk
      end
    end

    def self.run! port=9292
      middlewares.unshift Rack::ShowExceptions, Rack::CommonLogger

      begin
        Rack::Handler::Thin
      rescue LoadError
        Rack::Handler::WEBrick
      end.run new, :Port => port
    end

    def handler_for_path method, path
      self.class.routes.fetch(method.downcase.to_sym).each do |sig, h|
        params = sig.match path
        return [h, params] if params
      end

      raise RouteNotFoundError
    end

    def route req
      begin
        handler, params = handler_for_path req.request_method, req.path
        req.params.merge! params
        RequestScope.new(self, req).apply_to &handler
      rescue KeyError, RouteNotFoundError
        @app.call req.env
      end
    end

    def _call env
      route Request.new(env)
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
