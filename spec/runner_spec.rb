require 'spec_helper'

describe 'App.run!' do
  let (:kls) { mock_app_class {} }

  before do
    Rack::Handler.stub :pick => double(:run => nil)
  end

  it 'should include the default middleware on top' do
    kls.should_receive(:use).with(Rack::CommonLogger)
    kls.should_receive(:use).with(BetterErrors::Middleware)
    kls.run!
  end

  it 'should not include show exceptions middleware in production' do
    NYNY.env.stub :production? => true
    kls.should_receive(:use).with(Rack::CommonLogger)
    kls.should_not_receive(:use).with(BetterErrors::Middleware)
    kls.run!
  end

end
