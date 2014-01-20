module NYNY
  module Runner
    PREFERRED_SERVERS = ['puma', 'thin', 'webrick']

    def run! port=9292
      use Rack::CommonLogger
      use Rack::ShowExceptions unless NYNY.env.production?
      Rack::Handler.pick(PREFERRED_SERVERS).run new, :Port => port
    end
  end
end
