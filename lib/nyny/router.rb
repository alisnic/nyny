module NYNY
  class Router
    attr_reader :fallback, :routes, :before_hooks, :after_hooks, :scope_class
    def initialize options
      @fallback     = options[:fallback]
      @routes       = options[:routes]
      @before_hooks = options[:before_hooks]
      @after_hooks  = options[:after_hooks]
      @scope_class  = options[:scope_class]
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
      request.params.default_proc = proc { |h, k|
        h.fetch(k.to_s, nil) || h.fetch(k.to_sym, nil)
      }

      eval_response scope_class.new(request), route.handler
    end

    def eval_response scope, handler
      response = catch (:halt) do
        before_hooks.each {|h| scope.instance_eval &h }
        scope.apply_to &handler
      end

      catch (:halt) do
        after_hooks.each {|h| scope.instance_eval &h }
      end

      response
    end
  end
end
