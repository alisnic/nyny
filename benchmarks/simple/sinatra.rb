#!ruby -I ../../lib -I lib
require 'sinatra'

class App < Sinatra::Base
  get '/' do
    'Hello World!'
  end
end

