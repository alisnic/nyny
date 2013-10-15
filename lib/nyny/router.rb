module NYNY
  class Router
    NullHandler = Class.new

    attr_reader :fallback, :routes, :before_hooks, :after_hooks
    def initialize options
      @fallback     = options[:fallback]
      @routes       = options[:routes]
      @before_hooks = options[:before_hooks]
      @after_hooks  = options[:after_hooks]
    end

    def call env
      env['PATH_INFO'] = '/' if env['PATH_INFO'].empty?
      route = routes.find {|route| route.match? env }

      if route
        process route, env
      else
        fallback.call env
      end
    end

    def process route, env
      request = Request.new(env)
      request.params.merge! route.url_params(env)
      request.params.default_proc = proc {|h,k| h[k.to_s] || h[k.to_sym]}

      eval_response RequestScope.new(request), route.handler
    end

    def eval_response scope, handler
      catch (:halt) do
        before_hooks.each {|h| scope.instance_eval &h }
        response = scope.apply_to &handler
        after_hooks.each {|h| scope.instance_eval &h }
        response
      end
    end
  end
end
