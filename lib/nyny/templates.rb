require 'tilt'

module NYNY
  module Templates
    module Helpers
      def render template, locals = {}, options = {}, &block
        template_cache.fetch(template) do
          Tilt.new(template, options)
        end.render(self, locals, &block)
      end

      def template_cache
        Thread.current[:template_cache] ||= Tilt::Cache.new
      end
    end

    def self.registered app
      app.helpers Helpers
    end
  end
end