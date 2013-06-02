require_relative 'spec_helper'

describe ClassMethods do
  let (:app_class) { Class.new(App) }
  describe 'middlewares' do
    before do
      app_class.class_eval do
        use NullMiddleware
      end
    end

    it 'should allow to add a middleware' do
      app_class.middlewares.last.first.should == NullMiddleware
    end

    it 'should call the middleware when called' do
      NullMiddleware.any_instance.should_receive :call
      response = mock_request :get, random_url, app_class
    end
  end

  describe 'helpers' do
    it 'should allow to include a helper in request scope' do
      app_class.helpers NullHelper
      RequestScope.ancestors.should include(NullHelper)
    end

    it 'should allow to include multiple helpers modules' do
      module NullHelper2
      end

      app_class.helpers NullHelper, NullHelper2
      RequestScope.ancestors.should include(NullHelper, NullHelper2)
    end
  end
end
