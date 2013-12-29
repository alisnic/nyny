module NYNY
  class App
    HTTP_VERBS = [:delete, :get, :head, :options, :patch, :post, :put, :trace]
    BUILDER    = Rack::Builder.new

    def initialize app=nil
      self.class.builder.run Router.new({
        :routes       => self.class.routes,
        :fallback     => (app || lambda {|env| Response.new '', 404 }),
        :before_hooks => self.class.before_hooks,
        :after_hooks  => self.class.after_hooks
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

      def routes;       @routes       ||= []  end
      def before_hooks; @before_hooks ||= []  end
      def after_hooks;  @after_hooks  ||= []  end

      def builder
        @builder ||= BUILDER.dup
      end

      def register *extensions
        extensions.each do |ext|
          extend ext
          ext.registered(self) if ext.respond_to?(:registered)
        end
      end

      def namespace url, &block
        builder.map url do
          use Class.new(NYNY::App, &block)
        end
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
        args.each {|m| RequestScope.add_helper_module m }
      end
    end #class methods
  end
end
