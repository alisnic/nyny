require 'spec_helper'

describe Templates do
  let (:app_class) do
    mock_app_class do
      helpers do
        def template_root
          File.join(__dir__, "views")
        end
      end

      get '/without_layout' do
        render template('index.erb')
      end

      get '/with_layout' do
        render template('layout.erb') do
          render template('index.erb')
        end
      end

      get '/instance_var' do
        @foo = 'bar'
        render template('instance.erb')
      end

      get '/via_helper' do
        erb :index
      end

      get '/local_var' do
        render template('local.erb'), :foo => 'bar'
      end
    end
  end

  let (:app) { Rack::MockRequest.new(app_class.new)}

  it 'renders correctly without layout' do
    response = app.get('/without_layout')
    response.body.should == '<p>Hello!</p>'
  end

  it 'passes a instance variable to template' do
    response = app.get('/instance_var')
    response.body.should == 'bar'
  end

  it 'passes a local variable to template' do
    response = app.get('/local_var')
    response.body.should == 'bar'
  end

  it 'renders correctly with layout' do
    response = app.get('/with_layout')

    rendered = Tilt.new(template('layout.erb')).render do
      Tilt.new(template('index.erb')).render
    end

    response.body.should == rendered
  end

  it 'defines helpers for all tilt supported engines' do
    Tilt.default_mapping.lazy_map.keys.each do |ext|
      app_class.scope_class.instance_methods.should include(ext.to_sym)
    end
  end
end
