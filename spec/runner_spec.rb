require 'spec_helper'

describe Runner do
  describe '.run!' do
    before do
      handler = begin
                  Rack::Handler::Thin
                rescue LoadError
                  Rack::Handler::WEBrick
                end
      handler.stub :run
    end

    it 'should include the default middleware on top' do
      kls = mock_app_class do
      end

      kls.run!
      kls.middlewares.first.should == Rack::ShowExceptions
      kls.middlewares[1].should == Rack::CommonLogger
    end
  end
end
