require 'spec_helper'

describe NYNY do
  it 'root points to pwd' do
    NYNY.root.should == Pathname.pwd
  end

  it 'has the correct env' do
    NYNY.env.should be_test
  end

  it 'root can join a path' do
    NYNY.root.join("foo").should == Pathname.pwd + "foo"
  end
end
