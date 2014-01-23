require 'better_errors'

module NYNY
  module Runner
    def run! port=9292
      use Rack::CommonLogger
      use BetterErrors::Middleware unless NYNY.env.production?
      Rack::Handler.pick(['thin', 'webrick']).run new, :Port => port
    end
  end
end
