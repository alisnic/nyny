require './lib/little_frank'

class App < LittleFrank::App
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
      [username, password] == ['admin', 'admin']
  end
  use Rack::Static, :urls => ["/spec"]

  get '/' do
    params.to_s
  end

  get '/google' do
    redirect_to 'http://google.com'
  end
end

run App.new
