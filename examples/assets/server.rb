#!ruby -I ../../lib -I lib
require 'bundler'

ENV['RACK_ENV'] ||= 'development'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

class App < NYNY::App
  map '/assets' do
    environment = Sprockets::Environment.new
    environment.append_path 'app/assets/javascripts'
    environment.append_path 'vendor/javascripts'
    run environment
  end

  get '/' do
    render 'app/views/index.haml'
  end
end

App.run! if __FILE__ == $0
