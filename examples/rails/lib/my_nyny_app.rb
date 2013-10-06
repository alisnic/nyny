require 'nyny'

class MyNYNYApp < NYNY::App
  get '/' do
    'Hello from "New York, New York!"'
  end
end
