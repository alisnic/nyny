#!ruby -I ../../lib -I lib
require 'nyny'

class App < NYNY::App
  get '/' do
    render 'app/views/index.haml'
  end
end

App.run!
