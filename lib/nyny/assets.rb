module NYNY
  module Assets
    module Helpers
      #
    end

    def assets options
      require 'sprockets'

      sprockets = Sprockets::Environment.new
      options.fetch(:paths, []).each {|path| sprockets.append_path(path)}
      sprockets = sprockets.index if NYNY.env.production?
      builder.map (options.fetch(:url, '/assets')) { run sprockets }
    rescue LoadError
      puts "To use asset pipeline, install the 'sprockets' gem"
    end

    def self.registered app
      app.helpers Helpers
    end
  end
end