#!ruby -I ./lib -I lib
require 'nyny'
require 'ruby-prof'
require 'benchmark'
require 'sinatra'
include Benchmark

set :run, false #do not run sinatra's builtin web server

def build_apps &block
  sinatra = Class.new(Sinatra::Base, &block).new
  nyny    = Class.new(NYNY::App, &block).new
  return [nyny, sinatra].map {|app| Rack::MockRequest.new(app) }
end

def run_test name, apps, &block
  nyny, sinatra = apps
  prc = Proc.new(&block)

  puts "\nTest: #{name}"
  Benchmark.benchmark(CAPTION, 7, FORMAT, "> NYNY/Sinatra:") do |x|
    nyny_time     = x.report("nyny:   ")  { 1000.times { prc.call(nyny) } }
    sinatra_time  = x.report("sinatra:")  { 1000.times { prc.call(sinatra) } }
    puts "NYNY is #{"%.2f" % [sinatra_time.real/nyny_time.real]}x faster than Sinatra in this test"
  end
end

puts "Comparing NYNY #{NYNY::VERSION} with Sinatra #{Sinatra::VERSION}"

#
# Empty app
apps = build_apps do
  #empty app
end
run_test 'empty', apps do |app|
  app.get '/'
end

#
# Hello World
apps = build_apps do
  get '/' do
    'Hello World'
  end
end
run_test 'hello world', apps do |app|
  app.get '/'
end

#
# Filters
apps = build_apps do
  before do
    request
  end

  after do
    response
  end

  get '/' do
    'Hello World!'
  end
end
run_test 'filters', apps do |app|
  app.get '/'
end

#
# Helpers
apps = build_apps do
  helpers do
    def da_request
      request
    end
  end

  get '/' do
    da_request
  end
end
run_test 'helpers', apps do |app|
  app.get '/'
end

#
# Url patterns
apps = build_apps do
  get '/:name' do
    params[:name]
  end
end
run_test 'Url patterns', apps do |app|
  app.get '/foo'
end

# Plain routes
apps = build_apps do
  [:get, :post, :put].each do |method|
    10.times do |i|
      send(method, "/foo/#{i}") do
        i
      end
    end
  end
end
run_test 'A lot o Plain routes', apps do |app|
  app.get '/foo/5'
end

#
# Pattern routes
apps = build_apps do
  [:get, :post, :put].each do |method|
    10.times do |i|
      send(method, "/foo/#{i}/:action") do
        params[:action]
      end
    end
  end
end
run_test 'A lot of Pattern routes', apps do |app|
  app.get '/foo/5/edit'
end

