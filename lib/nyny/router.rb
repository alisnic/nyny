require 'active_support/concern'
require 'action_dispatch/routing'
require 'action_dispatch/journey'

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
      routes = ActionDispatch::Journey::Routes.new
      @journey = ActionDispatch::Journey::Router.new(routes, {
        :parameters_key => 'nyny.params'
      })

      route_defs.each do |path, options, handler|
        pat         = ActionDispatch::Journey::Path::Pattern.new(path)
        constraints = options.fetch(:constraints, {})
        defaults    = options.fetch(:defaults, {})

        @journey.routes.add_route compile(handler), pat, constraints, defaults
      end
    end

    def compile handler
      Proc.new do |env|
        scope = scope_class.new(env)

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