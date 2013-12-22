require 'spec_helper'

describe Templates do
  let (:app) do
    mock_app do
      get '/without_layout' do
        render template('index.erb')
      end

      get '/with_layout' do
        render template('layout.erb') do
          render template('index.erb')
        end
      end
    end
  end

  it 'render correctly without layout' do
    response = app.get('/without_layout')
    response.body.should == '<p>Hello!</p>'
  end

  it 'render correctly with layout' do
    response = app.get('/with_layout')

    rendered = Tilt.new(template('layout.erb')).render do
      Tilt.new(template('index.erb')).render
    end

    response.body.should == rendered
  end

end
