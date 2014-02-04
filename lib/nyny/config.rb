module NYNY
  module Config
    def config
      scope_class.config
    end

    def configure *envs, &block
      if envs.map(&:to_sym).include?(NYNY.env.to_sym) or envs.empty?
        yield config
      end
    end

    def self.registered app
      app.scope_class.class.send :attr_accessor, :config
      app.scope_class.config = OpenStruct.new

      app.helpers do
        def config
          self.class.config
        end
      end
    end
  end
end