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

    def find_handler request
      routes.fetch(request.request_method.downcase.to_sym, []).each do |sig, h|
        params = sig.match request.path
        return [h, params] if params
      end

      [NullHandler, {}]
    end

    def call env
      req = Request.new(env)
      handler, params = find_handler req

      if handler != NullHandler
        process req, handler, params
      else
        fallback.call env
      end
    end

    def process request, handler, url_params
      request.params.merge! url_params
      request.params.default_proc = proc {|h,k| h[k.to_s] || h[k.to_sym]}

      scope = RequestScope.new(request)
      catch (:halt) do
        before_hooks.each {|h| scope.instance_eval &h }
        response = scope.apply_to &handler
        after_hooks.each {|h| scope.instance_eval &h }
        response
      end
    end
  end
end
