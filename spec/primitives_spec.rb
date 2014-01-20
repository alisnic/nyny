require 'spec_helper'

describe 'NYNY primitives' do
  describe NYNY::Response do
    it 'allows to rewrite the response' do
      resp = NYNY::Response.new
      resp.write 'foo'
      resp.rewrite 'banana'
      resp.headers['Content-Length'].should == "6"
      resp.body.first.should == 'banana'
    end
  end
end