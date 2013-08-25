#!ruby -I ../lib -I lib
require 'nyny'
require 'sinatra'
require 'ostruct'

module Views
  CACHE = Tilt::Cache.new
  include ::Sinatra::Templates

  def settings
    @settings ||= OpenStruct.new :templates => {}
  end

  def template_cache
    CACHE
  end
end


class App < NYNY::App
  helpers Views

  get '/' do
    haml :index
  end
end

App.run!
