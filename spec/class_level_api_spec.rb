require 'spec_helper'

describe 'Class level api' do
  let (:app_class) { Class.new(App) }
  describe 'middlewares' do
    let (:app_class) do
      frankie_app do
        use NullMiddleware
      end
    end

    it 'should allow to add a middleware' do
      app_class.middlewares.last.first.should == NullMiddleware
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
