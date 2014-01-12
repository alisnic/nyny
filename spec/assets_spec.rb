require 'spec_helper'

describe NYNY::Assets, :broken => true do
  let! (:app_kls) do
    mock_app_class {}
  end

  let (:app) do
    Rack::MockRequest.new(app_kls.new)
  end

  it '.assets should be a sprockets environment' do
    app_kls.assets.should be_a(Sprockets::Environment)
  end

  it 'should include the classic paths in the search' do
    app_kls.assets.paths.should == [
      File.join(NYNY.root, 'app', 'assets', 'javascripts'),
      File.join(NYNY.root, 'app', 'assets', 'stylesheets'),
      File.join(NYNY.root, 'app', 'assets', 'images')
    ]
  end

  it 'delegates to the environment on /assets' do
    kls = mock_app_class do
      assets.prepend_path File.join(__dir__, 'assets')
    end

    app = Rack::MockRequest.new(kls.new)
    response = app.get('/assets/application.js')
    response.status.should == 200
    response.body.should == "console.log('dependency');\nconsole.log('application');\n"
  end
end