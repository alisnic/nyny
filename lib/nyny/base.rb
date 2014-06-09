require 'rack'
require 'nyny/primitives'
require 'nyny/request_scope'
require 'nyny/router'

module NYNY
  class Base
    include NYNY::Inheritable
    HTTP_VERBS = [:delete, :get, :head, :options, :patch, :post, :put, :trace]

    inheritable :scope_class,         Class.new(RequestScope)
    inheritable :route_defs,          []
    inheritable :before_hooks,        []
    inheritable :after_hooks,         []
    inheritable :before_init_hooks,   []
    inheritable :after_init_hooks,    []
    inheritable :default_constraints, {}
    inheritable :middlewares,         []
    inheritable :map,                 {}

    def initialize app=nil
      builder = Rack::Builder.new

      self.class.before_init_hooks.each {|h| h.call(self)}

      self.class.middlewares.each do |m, args, blk|
        builder.use m, *args, &blk
      end

      self.class.map.each {|url, klass| builder.map(url) { use klass } }

      builder.run Router.new({
        :scope_class    => self.class.scope_class,
        :route_defs     => self.class.route_defs,
        :before_hooks   => self.class.before_hooks,
        :after_hooks    => self.class.after_hooks,
        :fallback       => app
      })

      @app = builder.to_app
      self.class.after_init_hooks.each {|h| h.call(self, @app)}
    end

    def call env
      @app.call env
    end

    #class methods
    class << self
      HTTP_VERBS.each do |method|
        define_method method do |path, options={}, &block|
          options[:constraints] = default_constraints.merge(options[:constraints] || {})
          options[:constraints].merge!(:request_method => method.to_s.upcase)
          define_route path, options, &block
        end
      end

      def namespace url, &block
        scope  = self.scope_class

        map[url] = Class.new self.superclass do
          self.scope_class = scope
          class_eval(&block)
        end
      end

      def define_route path, options, &block
        self.route_defs << [path, options, Proc.new(&block)]
      end

      def constraints args, &block
        current = self.default_constraints.dup
        self.default_constraints = args
        instance_eval &block
        self.default_constraints = current
      end

      def before &blk
        before_hooks << Proc.new(&blk)
      end

      def after &blk
        after_hooks << Proc.new(&blk)
      end

      def before_initialize &blk
        before_init_hooks << Proc.new(&blk)
      end

      def after_initialize &blk
        after_init_hooks << Proc.new(&blk)
      end

      def use middleware, *args, &block
        middlewares << [middleware, args, block]
      end

      def register *extensions
        extensions.each do |ext|
          extend ext
          ext.registered(self) if ext.respond_to?(:registered)
        end
      end

      def helpers *args, &block
        args << Module.new(&block) if block_given?
        args.each {|m| scope_class.send :include, m }
      end
    end #class methods
  end
end
