Rails.application.routes.draw do
  get "dashboard", to: "dashboard#index"
  resources :jobs
  devise_for :users
  resource :profile, only: [:edit,:update]
  root "jobs#index"
  resources :resumes
  get "up" => "rails/health#show", as: :rails_health_check  
end
