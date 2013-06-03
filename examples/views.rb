#!ruby -I ../lib -I lib
require 'frankie'
require 'sinatra'
require 'ostruct'

module SinatraSettingsStub
  def settings
    @settings ||= OpenStruct.new :templates => {}
  end

  def template_cache
    @template_cache = Tilt::Cache.new
  end
end


class App < Frankie::App
  helpers SinatraSettingsStub, ::Sinatra::Templates

  get '/' do
    haml :index
  end
end

Rack::Handler::Thin.run App.new, :Port => 9000
