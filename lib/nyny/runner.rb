module NYNY
  module Runner
    def optimal_runner
      return Rack::Handler::WEBrick if RUBY_PLATFORM == 'java'

      begin
        Rack::Handler::Thin
      rescue LoadError
        Rack::Handler::WEBrick
      end
    end

    def before_run_hooks; @before_run_hooks ||= []; end

    def before_run &blk
      before_run_hooks << Proc.new(&blk)
    end

    def run! port=9292
      middlewares.unshift Rack::ShowExceptions, Rack::CommonLogger
      before_run_hooks.each {|hook| instance_eval(&hook) }
      optimal_runner.run new, :Port => port
    end
  end
end
