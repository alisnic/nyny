#!ruby -I ../../lib -I lib
require 'nyny'
require 'sprockets'
require 'haml'
require 'coffee_script'

class App < NYNY::App
  assets :url => '/assets', :paths => [
    'vendor/javascripts',
    'app/assets/javascripts',
    'app/assets/stylesheets',
    'app/assets/images'
  ]

  get '/' do
    render 'app/views/index.haml'
  end
end

App.run!
