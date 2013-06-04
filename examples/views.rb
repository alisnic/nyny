#!ruby -I ../lib -I lib
require 'frankie'
require 'sinatra'
require 'ostruct'

module Views
  include ::Sinatra::Templates

  def settings
    @settings ||= OpenStruct.new :templates => {}
  end

  def template_cache
    @template_cache = Tilt::Cache.new
  end
end


class App < Frankie::App
  helpers Views

  get '/' do
    haml :index
  end
end

App.run!
