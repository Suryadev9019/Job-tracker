Rails.application.routes.draw do
  resources :jobs
  devise_for :users
  resource :profile, only: [:edit,:update]
  root "jobs#index"
  get "up" => "rails/health#show", as: :rails_health_check

  
end
