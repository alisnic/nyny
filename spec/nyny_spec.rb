require 'spec_helper'

describe NYNY do
  it '.root points to pwd' do
    NYNY.root.should == Dir.pwd
  end
end
