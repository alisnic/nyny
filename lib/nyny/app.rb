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
    inheritable :routes,        []
    inheritable :before_hooks,  []
    inheritable :after_hooks,   []
    inheritable :scope_class,   Class.new(RequestScope)

    def initialize app=nil
      self.class.builder.run Router.new({
        :routes       => self.class.routes,
        :fallback     => (app || lambda {|env| Response.new '', 404 }),
        :before_hooks => self.class.before_hooks,
        :after_hooks  => self.class.after_hooks,
        :scope_class  => self.class.scope_class
      })
    end

    def call env
      self.class.builder.call env
    end

    #class methods
    class << self
      HTTP_VERBS.each do |method|
        define_method method do |str, &blk|
          routes << Route.new(method, str, &blk)
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
