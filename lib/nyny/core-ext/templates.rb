module NYNY
  module Templates
    module Helpers
      def render(template, locals = {}, options = {}, &block)
        templates_cache.fetch(template) {
          Tilt.new(template, options)
        }.render(self, locals, &block)
      end

      def templates_cache
        Thread.current[:templates_cache] ||= Tilt::Cache.new
      end
    end

    def self.registered app
      app.helpers Helpers
    end
  end
end