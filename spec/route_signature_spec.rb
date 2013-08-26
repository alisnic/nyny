require 'spec_helper'

describe RouteSignature do
  it 'should have the initial regexp as the pattern' do
    exp = /[w+]/
    sig = RouteSignature.new exp
    sig.pattern.should == exp
  end
end
