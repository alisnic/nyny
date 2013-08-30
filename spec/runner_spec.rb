require 'spec_helper'

describe Runner do
  let (:kls) { mock_app_class {} }

  before do
    handler = begin
                Rack::Handler::Thin
              rescue LoadError
                Rack::Handler::WEBrick
              end
    handler.stub :run
  end

  it 'should include the default middleware on top' do
    kls.run!
    kls.middlewares.first.should == Rack::ShowExceptions
    kls.middlewares[1].should == Rack::CommonLogger
  end

  it 'should support before run hooks' do
    prc = Proc.new { 'foo' }
    kls.before_run &prc
    kls.should_receive(:instance_eval).with(&prc)
    kls.run!
  end
end
