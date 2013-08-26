module NYNY
  class MiddlewareChain

    class << self
      def middlewares;  @middlewares  ||= []  end

      def add_middleware middleware, *args, &block
        middlewares << [middleware, args, block]
      end
    end

    def initialize middlewares, proxy
      @top = middlewares.reverse.reduce (proxy) do |prev, entry|
        klass, args, blk = entry
        klass.new prev, *args, &blk
      end
    end

    def call env
      @top.call(env)
    end
  end
end
