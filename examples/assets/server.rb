#!ruby -I ../../lib -I lib
require 'nyny'
require 'sprockets'
require 'haml'
require 'coffee_script'

class App < NYNY::App
  sprockets = Sprockets::Environment.new do |env|
    env.append_path 'vendor/javascripts'
    env.append_path 'app/assets/javascripts'
    env.append_path 'app/assets/stylesheets'
    env.append_path 'app/assets/images'
  end

  builder.map '/assets' do
    run sprockets
  end

  get '/' do
    render 'app/views/index.haml'
  end
end

App.run!
