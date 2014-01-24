require 'journey'

module NYNY
  class Router
    attr_reader :scope_class, :journey, :before_hooks, :after_hooks, :fallback
    def initialize options
      @scope_class    = options[:scope_class]
      @before_hooks   = options[:before_hooks]
      @after_hooks    = options[:after_hooks]
      @fallback       = options[:fallback]

      prepare_for_journey(options[:route_defs])
    end

    def call env
      response = journey.call(env)

      if response[0] == 404 and fallback
        fallback.call(env)
      else
        response
      end
    end

    private

    def prepare_for_journey route_defs
      routes = Journey::Routes.new

      route_defs.each do |path, constraints, defaults, handler|
        pat = Journey::Path::Pattern.new(path)
        routes.add_route compile(handler), pat, constraints, defaults
      end

      @journey = Journey::Router.new(routes, {
        :parameters_key => 'nyny.params',
        :request_class  => Request
      })
    end

    def compile handler
      Proc.new do |env|
        request = Request.new(env)
        request.params.merge! env["nyny.params"]
        request.params.default_proc = lambda do |h, k|
          h.fetch(k.to_s, nil) || h.fetch(k.to_sym, nil)
        end

        scope = scope_class.new(request)

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
end