require 'nyny'
require 'ruby-prof'
require 'benchmark'

class App < NYNY::App
  get '/' do
    'Hello'
  end
end

app = Rack::MockRequest.new(App.new)

#RubyProf.start
Benchmark.bm do |x|
  x.report { 1000.times {app.get('/')} }
end

#result = RubyProf.stop

# Print a flat profile to text
#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT)
