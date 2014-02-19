require 'spec_helper'

describe RequestScope do
  let (:env) { Rack::MockRequest.env_for '/', :params => {:some => 'param'} }
  let (:subject) { RequestScope.new env.merge('nyny.params' => {}) }
  let (:dummy_request) { subject.request }
  let (:handler) {
    Proc.new {"hello"}
  }

  describe 'exposed methods' do
    its (:params) { should == dummy_request.params }
    its (:cookies) { should == dummy_request.cookies }
    its (:session) { should == dummy_request.session }

    it 'params should have insensitive keys' do
      app = mock_app do
        get '/' do
          params[:foo][:bar].should == params['foo']['bar']
        end
      end

      app.get '/', :params => {:foo => {:bar => 'baz'}}
    end

    describe 'cookies' do
      let (:app) do
        mock_app do
          post '/cookie' do
            cookies['foo'] = 'bar'
          end

          post '/cookie_halt' do
            cookies['foo'] = 'bar'
            halt 200, {}, 'blah'
            cookies['foo'] = 'moo'
          end

          delete '/cookie' do
            cookies.delete 'foo'
          end

          delete '/cookie_halt' do
            cookies.delete 'foo'
            halt 200, {}, 'blah'
            cookies[:foo] = 'bar'
          end
        end
      end

      it 'sets a cookie' do
        res = app.post '/cookie'
        res.headers['Set-Cookie'].should == 'foo=bar; path=/'
      end

      it 'deletes a cookie' do
        app.post '/cookie'
        res = app.delete '/cookie'
        res.headers['Set-Cookie'].should_not include('foo=bar')
      end

      describe 'when response was halted' do
        it 'sets a cookie' do
          res = app.post '/cookie_halt'
          res.headers['Set-Cookie'].should == 'foo=bar; path=/'
        end

        it 'deletes a cookie' do
          app.post '/cookie'
          res = app.delete '/cookie_halt'
          res.headers['Set-Cookie'].should_not include('foo=bar')
        end
      end
    end

    it '#headers should set the header values' do
      subject.headers['Head'] = 'Tail'
      response = subject.apply_to &handler
      response.headers['Head'].should == 'Tail'
    end

    it '#status should set the response status' do
      forbid = Proc.new { status 403 }
      response = subject.apply_to &forbid
      response.status.should == 403
    end

    it 'params should have insensitive keys' do
      app = mock_app do
        get '/' do
          params[:foo].should == params['foo']
        end
      end

      app.get '/?foo=bar'
    end

    it 'halt in a before block should override the response' do
      prc = Proc.new { 'da block' }

      app = mock_app do
        before do
          halt 302
        end

        get '/', &prc
      end

      res = app.get '/'
      res.status.should == 302
      prc.should_not_receive(:call)
    end

    it 'should halt if the statement is in the route definition' do
      app = mock_app do
        get '/' do
          halt 200, {}, 'Halted'
          'shouldnt be returned'
        end
      end
      res = app.get '/'
      res.status.should == 200
      res.body.should == 'Halted'
    end

    it 'return prematurely with pass' do
      app = mock_app do
        get '/' do
          next 'blah'
          'shouldnt be returned'
        end
      end
      res = app.get '/'
      res.status.should == 200
      res.body.should == 'blah'
    end

    it '#redirect_to should redirect' do
      redir = Proc.new { redirect_to 'http://foo.bar' }
      response = catch(:halt) { subject.apply_to &redir }
      response.status == 302
      response.headers['Location'].should == 'http://foo.bar'
    end
  end
end
