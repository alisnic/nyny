require 'spec_helper'

describe App do
  let (:klass) { mock_app_class {} }
  let (:app) { mock_app {} }

  it 'should return a rack response on call' do
    env = Rack::MockRequest.env_for '/'
    res = klass.new.call(env)
    res.should be_a(Array)
    res.size.should == 3
    res[0].should == 404
    res[1].should be_a(Hash)
    res[2].should respond_to(:each)
  end

  it 'can use the builder map method' do
    app = mock_app do
      map '/map' do
        run lambda {|env| [200, {}, ["map"]]}
      end

      get '/' do
        'root'
      end
    end

    app.get('/').body.should == 'root'
    app.get('/map').body.should == 'map'
  end

  it 'should return 404 for non-matched routes' do
    response = app.get random_url
    response.status.should == 404
  end

  it 'can use constraints block' do
    app = mock_app do
      constraints :content_type => 'text/html' do
        get '/' do
          'HTML!'
        end
      end

      get '/' do
        'not html'
      end
    end

    app.get('/').body.should == 'not html'
    app.get('/', 'CONTENT_TYPE' => 'text/html').body.should == 'HTML!'
  end

  it 'should able to register a extension' do
    module Foo
      def foo
      end
    end

    kls = mock_app_class {}
    kls.register(Foo)
    kls.should respond_to(:foo)
  end

  it 'should call registered method on extension' do
    module Foo
      def self.registered app
        #
      end
    end

    class SomeApp < NYNY::App
    end

    Foo.should_receive(:registered).with(SomeApp)
    SomeApp.register(Foo)
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
      get '/some/:name' do
        'foo'
      end

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
      [210, {'Content-Length' => 21}, ['Hello from downstream']]
    end

    app_class = mock_app_class do
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

  it 'works with empty path' do
    kls = mock_app_class do
      get '/' do
        'Hello'
      end
    end

    env = Rack::MockRequest.env_for '/'
    env['PATH_INFO'] = ''
    kls.new.call(env)[2].body.last.should == 'Hello'
  end

  describe 'Class level api' do
    let (:app_class) { Class.new(App) }

    describe 'middlewares' do
      it 'delegates to builder' do
        app = mock_app do
          use NullMiddleware

          get '/' do
            request.env['NULL'].should == true
          end
        end

        app.get('/')
      end
    end

    describe 'helpers' do
      it 'should allow to include a helper in request scope' do
        app_class.helpers NullHelper
        app_class.scope_class.ancestors.should include(NullHelper)
      end

      it 'should allow to include multiple helpers modules' do
        module NullHelper2
        end

        app_class.helpers NullHelper, NullHelper2
        app_class.scope_class.ancestors.should include(NullHelper, NullHelper2)
      end

      it 'should allow to define helpers with a block' do
        app_class.helpers do
          def foo
            'bar'
          end
        end

        app_class.get '/' do
          foo.should == 'bar'
        end
        req = Rack::MockRequest.env_for '/'
        res = app_class.new.call(req)
      end
    end
  end
end
