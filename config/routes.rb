Rails.application.routes.draw do

  root 'latest#index'
  get '/latest', to: 'latest#index'

  get 'admin/index'
  post 'admin/login'
  post 'admin/logout'
  scope '/admin' do
    resources :shirts, :sites
  end

end
