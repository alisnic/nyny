require 'spec_helper'

describe App do
  describe 'config' do
    let (:klass) do
      mock_app_class do
        get '/' do
          p config
          config.foo.should == 'bar'
        end
      end
    end

    let (:app) do
      Rack::MockRequest.new(klass.new)
    end

    it 'sets any property' do
      klass.config.foo = 'bar'
      klass.config.foo.should == 'bar'
    end

    it 'can configure multiple environments at once' do
      NYNY.stub :env => ['development', 'test'].sample

      kls = mock_app_class do
        configure :development, :test do
          config.test_dev = true
        end
      end

      kls.config.test_dev.should == true
      NYNY.unstub :env
    end

    it 'configures all environments by default' do
      kls = mock_app_class do
        configure do
          config.foo = true
        end
      end

      kls.config.foo.should == true
    end
  end
end
