module Frankie
  module ClassLevelApi
    HTTP_VERBS = [:delete, :get, :head, :options, :patch, :post, :put, :trace]
    HTTP_VERBS.each do |method|
      define_method method do |str, &blk|
        (routes[method] ||= {})[RouteSignature.new(str)] = Proc.new &blk
      end
    end

    def middlewares;  @middlewares ||= []   end
    def routes;       @routes ||= {}        end
    def before_hooks; @before_hooks ||=[]   end
    def after_hooks;  @after_hooks ||=[]    end

    def before &blk
      before_hooks << Proc.new(&blk)
    end

    def after &blk
      after_hooks << Proc.new(&blk)
    end

    def content_type type
      defaults[:headers]["Content-Type"] = type
    end

    def use middleware, *args, &block
      middlewares << [middleware, args, block]
    end

    def helpers *args
      args.each {|m| RequestScope.add_helper_module m }
    end
  end
end
