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

    inheritable :builder,       Rack::Builder.new
    inheritable :route_defs,    []
    inheritable :before_hooks,  []
    inheritable :after_hooks,   []
    inheritable :scope_class,   Class.new(RequestScope)

    def initialize app=nil
      routes = Journey::Routes.new

      self.class.route_defs.each do |path, constraints, defaults, handler|
        pat = Journey::Path::Pattern.new(path)
        routes.add_route self.class.build_route_app(handler), pat, constraints, defaults
      end

      self.class.builder.run Journey::Router.new(routes, {
        :parameters_key => 'nyny.params',
        :request_class  => Request
      })

      @app = self.class.builder.to_app
    end

    def call env
      @app.call env
    end

    #class methods
    class << self
      HTTP_VERBS.each do |method|
        define_method method do |path, constraints={}, defaults={}, &block|
          method_constraint = {:request_method => method.to_s.upcase}
          define_route path, constraints.merge(method_constraint), defaults, &block
        end
      end

      def define_route path, constraints, defaults={}, &block
        self.route_defs << [path, constraints, defaults, Proc.new(&block)]
      end

      def build_route_app handler
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

      def register *extensions
        extensions.each do |ext|
          extend ext
          ext.registered(self) if ext.respond_to?(:registered)
        end
      end

      def namespace url, &block
        app = Class.new(NYNY::App, &block)
        builder.map (url) { use app }
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
    end #class methods
  end
end
