require './lib/little_frank'

class App < LittleFrank::App
  get '/' do
    params.to_s
  end
end

run App.new
