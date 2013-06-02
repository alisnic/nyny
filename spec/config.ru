require './lib/frankie'

class App < Frankie::App
  get '/:first/:last' do
    params[:first] + params[:last]
  end
end

run App.new
