require 'sprockets'

module NYNY
  module Assets
    def assets
      @assets ||= Sprockets::Environment.new(NYNY.root) do |env|
        env.logger = NYNY.logger
      end
    end

    def self.registered app
      app.assets.append_path File.join('app', 'assets', 'javascripts')
      app.assets.append_path File.join('app', 'assets', 'stylesheets')
      app.assets.append_path File.join('app', 'assets', 'images')

      app::BUILDER.map '/assets' do
        if NYNY.env.production?
          run app.assets.index #cached sprockets env in production
        else
          run app.assets
        end
      end
    end
  end
end