require 'rack'
require 'better_errors'

require 'nyny/primitives'
require 'nyny/request_scope'
require 'nyny/router'
require 'nyny/templates'

module NYNY
  class App
    HTTP_VERBS = [:delete, :get, :head, :options, :patch, :post, :put, :trace]

    def self.inheritable name, value
      @_inheritables ||= []
      @_inheritables << name
      self.class.send :attr_accessor, name
      self.send "#{name}=", value
    end

    def self.inherited subclass
      @_inheritables.each do |attr|
        subclass.send "#{attr}=", self.send(attr).clone
        subclass.instance_variable_set "@_inheritables", @_inheritables.clone
      end

      super
    end

    inheritable :builder,         Rack::Builder.new
    inheritable :route_defs,      []
    inheritable :before_hooks,    []
    inheritable :after_hooks,     []
    inheritable :scope_class,     Class.new(RequestScope)

    def initialize app=nil
      self.class.builder.run Router.new({
        :scope_class    => self.class.scope_class,
        :route_defs     => self.class.route_defs,
        :before_hooks   => self.class.before_hooks,
        :after_hooks    => self.class.after_hooks,
        :fallback       => app
      })

      @app = self.class.builder.to_app
    end

    def call env
      @app.call env
    end

    #class methods
    class << self
      HTTP_VERBS.each do |method|
        define_method method do |path, options={}, &block|
          options[:constraints] ||= {}
          options[:constraints].merge!(:request_method => method.to_s.upcase)
          define_route path, options, &block
        end
      end

      def define_route path, options, &block
        self.route_defs << [path, options, Proc.new(&block)]
      end

      def register *extensions
        extensions.each do |ext|
          extend ext
          ext.registered(self) if ext.respond_to?(:registered)
        end
      end

      def namespace url, &block
        scope  = self.scope_class

        klass = Class.new self.superclass do
          self.scope_class = scope
          class_eval(&block)
        end

        builder.map (url) { use klass }
      end

      def before &blk
        before_hooks << Proc.new(&blk)
      end

      def after &blk
        after_hooks << Proc.new(&blk)
      end

      def use middleware, *args, &block
        builder.use middleware, *args, &block
      end

      def helpers *args, &block
        args << Module.new(&block) if block_given?
        args.each {|m| scope_class.send :include, m }
      end

      def run! port=9292
        use Rack::CommonLogger
        use BetterErrors::Middleware unless NYNY.env.production?
        Rack::Handler.pick(['thin', 'webrick']).run new, :Port => port
      end
    end #class methods

    register NYNY::Templates
  end
end
