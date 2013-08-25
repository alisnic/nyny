module NYNY
  class App
    extend ClassLevelApi
    extend Runner
    include MiddlewareChain

    RouteNotFoundError = Class.new StandardError

    def initialize app=nil
      @app = app || lambda {|env| Response.new '', 404 }
      build_middleware_chain lambda {|env| _call(env)}
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
      invoke_middleware_chain env
    end
  end
end
