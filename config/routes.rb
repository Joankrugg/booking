Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }
  namespace :admin do
    root "categories#index"
    resources :categories
    resources :services
    resources :bookings, only: %i[index show]
  end

  # PUBLIC ROOT
  root "calendar#index"
  get "/calendar", to: "calendar#index"
  get "/widgets/calendar", to: "widgets#calendar", as: :widgets_calendar


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

    resources :bookings, only: [:new, :create] do
      member do
        get :success
        get :cancel
      end
    end
  end
  resources :bookings, only: [:show]
  post "/webhooks/stripe", to: "webhooks#stripe"
 
end
