module NYNY
  class App
    HTTP_VERBS = [:delete, :get, :head, :options, :patch, :post, :put, :trace]
    extend Runner

    attr_reader :middleware_chain, :router
    def initialize app=nil
      @router = Router.new({
        :routes => self.class.routes,
        :fallback => (app || lambda {|env| Response.new '', 404 }),
        :before_hooks => self.class.before_hooks,
        :after_hooks => self.class.after_hooks
      })
      @middleware_chain = MiddlewareChain.new(self.class.middlewares,
                                              lambda {|env| _call(env)})
    end

    def _call env
      router.call env
    end

    def call env
      middleware_chain.call env
    end

    #class methods
    class << self
      HTTP_VERBS.each do |method|
        define_method method do |str, &blk|
          (routes[method] ||= {})[RouteSignature.new(str)] = Proc.new &blk
        end
      end

      def middlewares;  @middlewares  ||= []  end
      def routes;       @routes       ||= {}  end
      def before_hooks; @before_hooks ||= []  end
      def after_hooks;  @after_hooks  ||= []  end

      def register *extensions
        extensions.each do |ext|
          extend ext
          ext.registered(self) if ext.respond_to?(:registered)
        end
      end

      def before &blk
        before_hooks << Proc.new(&blk)
      end

      def after &blk
        after_hooks << Proc.new(&blk)
      end

      def use middleware, *args, &block
        middlewares << [middleware, args, block]
      end

      def helpers *args
        args.each {|m| RequestScope.add_helper_module m }
      end
    end #class methods
  end
end
