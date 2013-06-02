require './lib/frankie'

class App < Frankie::App
  before do
    p params
  end

  after do
    p response
  end

  get '/:first/:last' do
    params[:first] + params[:last]
  end
end

run App.new
