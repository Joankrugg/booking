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
  root "calendar#door"
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
  post "/stripe/connect", to: "stripe_connect#create", as: :create_stripe_connect
  get  "/stripe/connect/return", to: "stripe_connect#return", as: :return_stripe_connect
  get  "/stripe/connect/refresh", to: "stripe_connect#refresh", as: :refresh_stripe_connect
  get "/subscription/new", to: "subscriptions#new", as: :new_subscription
  get "/subscription/success", to: "subscriptions#success", as: :subscription_success
  get "/provider/subscription/cancel", to: "subscriptions#cancel", as: :subscription_cancel
  post "/stripe/webhooks", to: "stripe_webhooks#create"



 
end
