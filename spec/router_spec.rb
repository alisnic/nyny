require 'spec_helper'

describe Router do
  let (:app) do
    mock_app do
      get '/' do
        halt 200, {}, "Bar"
        "Foo"
      end

      post '/' do
        params[:not_exist].to_s
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

  it "should not raise SystemStackError if any absent param is accessed" do
    expect { response = app.post('/') }.not_to raise_error SystemStackError
  end
end
