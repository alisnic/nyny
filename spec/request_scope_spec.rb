require_relative 'spec_helper'

describe RequestScope do
  let (:env) { Rack::MockRequest.env_for '/', :params => {:some => 'param'} }
  let (:dummy_request) { Rack::Request.new(env) }
  let (:defaults) { Frankie::App.defaults }
  let (:subject) { RequestScope.new Frankie::App.new, dummy_request }
  let (:handler) {
    Proc.new {"hello"}
  }

  it 'should be able to add a helper module' do
    RequestScope.add_helper_module NullHelper
    RequestScope.ancestors.should include(NullHelper)
  end

  describe 'exposed methods' do
    its (:params) { should == dummy_request.params }

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

    it '#redirect_to should redirect' do
      redir = Proc.new { redirect_to 'http://foo.bar' }
      response = subject.apply_to &redir
      response.status.should == 302
      response.headers['Location'].should == 'http://foo.bar'
    end

    it '#apply_to should return a Rack response' do
      response = subject.apply_to &handler
      response.should be_a(Rack::Response)
    end
  end
end
