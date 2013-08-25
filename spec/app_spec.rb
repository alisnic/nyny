require 'spec_helper'

describe App do
  let (:app) { mock_app {} }

  it 'should return a rack response on call' do
    response = app.get '/'
    response.should be_a(Rack::Response)
  end

  it 'should return 404 for non-matched routes' do
    response = app.get random_url
    response.status.should == 404
  end

  it 'should match a route for any supported verbs' do
    url = random_url
    verb = App::HTTP_VERBS.sample

    app = mock_app do
      send verb, url do
        'foo'
      end
    end

    res = app.send verb, url
    res.body.should == 'foo'
  end

  it 'should support route patterns' do
    app = mock_app do
      get '/:name' do
        "hello #{params[:name]}"
      end
    end

    res = app.get '/foo'
    res.body.should == "hello foo"
  end

  it 'should support adding before filers' do
    app = mock_app do
      before do
        request.should_not == nil
      end

      get '/' do
        "hello"
      end
    end

    app.get('/')
  end

  it 'does not maintain state between requests' do
    app = mock_app do
      get '/state' do
        @foo ||= "new"
        body = "Foo: #{@foo}"
        @foo = 'discard'
        body
      end
    end

    2.times do
      response = app.get('/state')
      response.should be_ok
      'Foo: new'.should == response.body
    end
  end

  it 'acts well as a middleware' do
    app = lambda do |env|
      [210, {}, ['Hello from downstream']]
    end

    app_class = frankie_app do
      get '/' do
        'hello'
      end
    end

    frankie = app_class.new(app)
    req = Rack::MockRequest.new frankie
    res = req.get '/'
    res.body.should == 'hello'

    res2 = req.get '/ither'
    res2.body.should == 'Hello from downstream'
  end

  it 'should support adding after filers' do
    app = mock_app do
      after do
        response.should_not == nil
      end

      get '/' do
        "hello"
      end
    end
    app.get '/'
  end

  it 'should be able to set cookies' do
    app_class = Class.new(App) do
      post '/write' do
        cookies.merge! params
      end
    end

    req = Rack::MockRequest.env_for '/write?foo=bar', :method => :post
    res = app_class.new.call(req)
    res.headers['Set-Cookie'].should == 'foo=bar'
  end

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
end
