Rails.application.routes.draw do
  devise_for :users

  # PROVIDER namespace
  namespace :provider do
    root "dashboard#index", as: :dashboard

    resources :services do
      resources :service_areas, only: [:index, :new, :create, :destroy]
      resources :availability_rules, only: [:index, :new, :create, :destroy]
      resources :availability_exceptions, only: [:index, :new, :create, :destroy]
    end
  end

  # PUBLIC
  resources :services, only: [:show] do
    get :availability
  end

  root "home#index"
end
