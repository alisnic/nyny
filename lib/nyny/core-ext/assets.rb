require 'sprockets'

class Sprockets::Environment
  def clone
    copy = super
    copy.instance_variable_set "@trail", copy.instance_variable_get("@trail").clone
    copy
  end
end

module NYNY
  module Assets
    def self.registered app
      assets = Sprockets::Environment.new(NYNY.root) do |env|
        env.append_path File.join('app', 'assets', 'javascripts')
        env.append_path File.join('app', 'assets', 'stylesheets')
        env.append_path File.join('app', 'assets', 'images')
      end

      app.attribute :assets, assets

      sprockets = if NYNY.env.production?
        app.assets.index #cached sprockets env in production
      else
        app.assets
      end

      app.builder.map ('/assets') { run sprockets }
    end
  end
end