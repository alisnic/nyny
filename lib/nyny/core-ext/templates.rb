require 'tilt'

module NYNY
  module Templates
    module Helpers
      def render template, locals = {}, options = {}, &block
        template_cache.fetch(template) do
          Tilt.new(template, options)
        end.render(self, locals, &block)
      end

      def template_root
        File.join(NYNY.root, "views")
      end

      def template_cache
        Thread.current[:template_cache] ||= Tilt::Cache.new
      end

      Tilt.default_mapping.lazy_map.keys.each do |engine|
        define_method engine do |*args|
          args[0] = File.join(template_root, args[0].to_s) + ".#{engine}"
          render(*args)
        end
      end
    end

    def self.registered app
      app.helpers Helpers
    end
  end
end