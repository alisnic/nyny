#!ruby -I ../../lib -I lib
ENV['RACK_ENV'] ||= 'development'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require_relative 'database'
Dir[File.dirname(__FILE__) + "/models/*.rb"].each {|file| require file }

TEMPLATE = DATA.read.freeze

class App < NYNY::App
  get '/' do
    shouts = Shout.all.reverse
    ERB.new(TEMPLATE).result(binding)
  end

  post '/shouts' do
    Shout.create :body => params[:body]
    redirect_to '/'
  end
end

App.run! 9000

__END__
<html>
<body>
  <form action="/shouts" method="post">
    <input type="text" name="body"></input>
    <input type="submit" value="SHOUT"></input>
  </form>
  <ul>
    <% shouts.each do |shout| %>
      <li><%= shout.body %>
    <% end %>
  </ul>
</body>
</html>
