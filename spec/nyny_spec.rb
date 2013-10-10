require 'spec_helper'

describe NYNY do
  it '.root points to pwd' do
    NYNY.root.should == Dir.pwd
  end

  it 'has the correct env' do
    NYNY.env.should be_test
  end
end
