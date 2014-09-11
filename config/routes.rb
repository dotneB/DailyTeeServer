Rails.application.routes.draw do

  root 'latest#index'
  get '/latest', to: 'latest#index'

  scope '/admin' do
    resources :shirts, :sites
  end

end
