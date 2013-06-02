require_relative 'spec_helper'

describe App do
  let (:app_class) { Class.new(App) }

  it 'should have the class methods included' do
    extended_modules_for(App).should include(ClassMethods)
  end

  it 'should return a rack response on call' do
    response = mock_request :get, '/'
    response.should be_a(Rack::Response)
  end

  it 'should return 404 for non-matched routes' do
    response = mock_request :get, random_url
    response.status.should == 404
  end

  it 'should match a route for any supported verbs' do
    url = random_url
    verb = ClassMethods::HTTP_VERBS.sample

    app_class.class_eval do
      send verb, url do
        'foo'
      end
    end

    res = mock_request verb, url, app_class
    res.body.first.should == 'foo'
  end

end
