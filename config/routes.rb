Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  # PUBLIC ROOT
  root "home#index"

  # PROVIDER ROOT (protégé)
  namespace :provider do
    root "dashboard#index"
    resources :services do
      resources :service_areas
      resources :availability_rules
      resources :availability_exceptions
    end
  end

  # PUBLIC SERVICES
  resources :services, only: [:index, :show] do
    get :availability, on: :member
    resources :bookings, only: [:new, :create]
  end

  resources :bookings, only: [:show]
  
end
