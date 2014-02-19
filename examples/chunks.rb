#!ruby -I ../lib -I lib
require 'nyny'
require 'json'

Slow = Enumerator.new do |y|
  y.yield "Wait for it...<br />"

  5.times do |c|
    y.yield(c.to_s)
    sleep 1
  end
end

class App < NYNY::App
  get '/' do
    Slow
  end
end

App.run!
