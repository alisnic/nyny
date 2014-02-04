require 'spec_helper'

describe NYNY::App do
  let (:target) { OpenStruct.new }

  let (:app) do
    mock_app_class do
      before_initialize do |app|
        app.is_a?(NYNY::App).should == true
        Rack::Builder.any_instance.should_receive(:to_app)
                     .and_return(Proc.new {})
      end

      after_initialize do |app, prc|
        app.is_a?(NYNY::App).should == true
        prc.respond_to?(:call).should == true
        Rack::Builder.any_instance.should_not_receive(:to_app)
      end
    end
  end

  it 'runs the hooks in the correct order' do
    app.new
  end
end