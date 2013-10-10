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

    def run! port=9292
      middlewares.unshift Rack::CommonLogger
      middlewares.unshift Rack::ShowExceptions unless NYNY.env.production?
      optimal_runner.run new, :Port => port
    end
  end
end
