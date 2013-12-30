require 'sprockets'

s = Sprockets::Environment.new

s.append_path File.join('app', 'assets', 'javascripts')
s.append_path File.join('app', 'assets', 'stylesheets')
s.append_path File.join('app', 'assets', 'images')

map '/assets' do
  use s
end

run lambda {|env|
  'hello!'
}
