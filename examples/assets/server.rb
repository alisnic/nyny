#!ruby -I ../../lib -I lib
require 'bundler'
ENV['RACK_ENV'] ||= 'development'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

class App < NYNY::App
  register Sprockets::NYNY

  config.assets.paths << 'vendor/javascripts'

  get '/' do
    render 'app/views/index.haml'
  end
end

App.run! if __FILE__ == $0
