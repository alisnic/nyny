require 'spec_helper'

describe NYNY do
  its 'root points to pwd' do
    NYNY.root.should == Pathname.pwd
  end

  it 'has the correct env' do
    NYNY.env.should be_test
  end

  its 'root can join a path' do
    NYNY.root.join("foo").should == Pathname.pwd + "foo"
  end
end
