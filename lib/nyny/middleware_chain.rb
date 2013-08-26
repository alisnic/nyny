module NYNY
  class MiddlewareChain
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
