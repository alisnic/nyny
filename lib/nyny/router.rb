module NYNY
  class Router
    attr_reader :fallback, :before_hooks, :after_hooks, :journey
    def initialize options
      @fallback     = options[:fallback]
      @before_hooks = options[:before_hooks]
      @after_hooks  = options[:after_hooks]
      build_journey options[:routes]
    end

    def build_journey routes
      @journey = Journey::Router.new(Journey::Routes.new, {})
      routes.each do |route|
        exp   = Journey::Router::Strexp.new route.signature, {}, ['/.?']
        path  = Journey::Path::Pattern.new exp
        app   = Proc.new {|env| process(route, env)}
        @journey.routes.add_route(app, path,
          {:request_method => route.method}, {})
      end
    end

    def call env
      response = journey.call(env)
      if response[0] != 404
        response
      else
        fallback.call(env)
      end
    end

    def process route, env
      request = Request.new(env)
      request.params.merge! route.url_params(env)
      request.params.default_proc = proc {|h,k| h[k.to_s] || h[k.to_sym]}

      eval_response RequestScope.new(request), route.handler
    end

    def eval_response scope, handler
      response = catch (:halt) do
        before_hooks.each {|h| scope.instance_eval &h }
        scope.apply_to &handler
      end

      catch (:halt) do
        after_hooks.each {|h| scope.instance_eval &h }
      end

      response.to_a
    end
  end
end
