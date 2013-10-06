require 'my_nyny_app'

Dummy::Application.routes.draw do
  mount MyNYNYApp.new => '/nyny'
  root :to => 'application#index'
end
