require 'spec_helper'

describe Runner do
  let (:kls) { mock_app_class {} }

  before do
    kls.optimal_runner.stub :run
  end

  it 'should include the default middleware on top' do
    kls.run!
    kls.middlewares.first.should == Rack::ShowExceptions
    kls.middlewares[1].should == Rack::CommonLogger
  end

end
