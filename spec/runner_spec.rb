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

  it 'should not include show exceptions middleware in production' do
    NYNY.env.stub :production? => true
    kls.run!
    kls.middlewares.should == [Rack::CommonLogger]
  end

end
