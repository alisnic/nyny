require 'spec_helper'

describe RequestScope do
  let (:env) { Rack::MockRequest.env_for '/', :params => {:some => 'param'} }
  let (:dummy_request) { Rack::Request.new(env) }
  let (:subject) { RequestScope.new dummy_request }
  let (:handler) {
    Proc.new {"hello"}
  }

  it 'should be able to add a helper module' do
    RequestScope.add_helper_module NullHelper
    RequestScope.ancestors.should include(NullHelper)
  end

  describe 'exposed methods' do
    its (:params) { should == dummy_request.params }
    its (:cookies) { should == dummy_request.cookies }
    its (:session) { should == dummy_request.session }

    it 'params should have insensitive keys' do
      app = mock_app do
        get '/' do
          params[:foo].should == params['foo']
        end
      end

      app.get '/?foo=bar'
    end

    it '#headers should set the header values' do
      subject.headers 'Head' => 'Tail'
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
          next 'hui'
          'shouldnt be returned'
        end
      end
      res = app.get '/'
      res.status.should == 200
      res.body.should == 'hui'
    end

    it '#redirect_to should redirect' do
      redir = Proc.new { redirect_to 'http://foo.bar' }
      response = catch(:halt) { subject.apply_to &redir }
      response.status.should == 302
      response.headers['Location'].should == 'http://foo.bar'
    end

    it '#apply_to should return a Rack response' do
      response = subject.apply_to &handler
      response.should be_a(Rack::Response)
    end
  end
end
