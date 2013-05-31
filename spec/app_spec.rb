require_relative 'spec_helper'

describe App do
  it { should respond_to(:call) }

  it 'should have the class methods included' do
    extended_modules_for(App).should include(ClassMethods)
  end

  it 'should return a rack-compatible array on call' do
    response = mock_request :get, '/'

    response.should be_a(Array)
    response.size.should == 3
    response[0].should be_a(Fixnum)
    response[1].should be_a(Hash)
    response[2].should respond_to(:each)
  end

  describe 'routing' do
    let (:app_class) { Class.new(App) }

    it 'should route GET' do
      url = random_url
      app_class.class_eval do
        get url do
          'foo'
        end
      end

      res = mock_request :get, url, app_class
      res[2].first.should == 'foo'
    end

    it 'should route POST' do
      url = random_url
      app_class.class_eval do
        post url do
          'foo'
        end
      end

      res = mock_request :post, url, app_class
      res[2].first.should == 'foo'
    end
  end
end
