require_relative 'spec_helper'

describe Request do
  let (:subject) { Request.new stub }

  it { should be_a(Rack::Request) }
end

describe Response do
  it { should be_a(Rack::Response) }

  describe '#raw_body' do
    it 'should be accesible when the response was initialized' do
      raw_body = stub
      res = Response.new raw_body
      res.raw_body.should == raw_body
    end

    it 'should accesible after body was set' do
      res = Response.new
      raw_body = stub
      res.body = raw_body
      res.raw_body.should == raw_body
    end
  end
end
