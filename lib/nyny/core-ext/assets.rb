require 'sprockets'

module NYNY
  module Assets
    def assets
      @assets ||= Sprockets::Environment.new(Dir.pwd) do |env|
        env.logger = Logger.new(STDOUT)
      end

      if NYNY.env.production?
        @assets = @assets.index
      else
        @assets
      end
    end

    def self.registered app
      app.assets.append_path File.join('app', 'assets', 'javascripts')
      app.assets.append_path File.join('app', 'assets', 'stylesheets')
      app.assets.append_path File.join('app', 'assets', 'images')
      app::BUILDER.map ('/assets') { run app.assets }
    end
  end
end