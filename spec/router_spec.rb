require 'spec_helper'

describe Router do
  let (:app) do
    mock_app do
      get '/' do
        halt 200, {}, "Bar"
        "Foo"
      end

      after do
        response.body = "Zaz"
      end
    end
  end

  it "should eval after blocks even if the request was halted" do
    response = app.get('/')
    response.body.should == "Zaz"
  end
end
