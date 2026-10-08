Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords" }
  root "modern_box#index"
  get "up", to: "rails/health#show"
  get "calendar", to: "concerts#index", as: :calendar
  get "disponibilites", to: "public_availabilities#index", as: :availabilities
  resources :concerts, path: "concerts", only: [:index]
  resources :groups, path: "groupes", only: [:index, :show]
  resources :skills, only: [:index, :show]
  get "skills/:skill_id/releases/:release_id/download", to: "skills#download", as: :skill_download_release
  namespace :member, path: "membre" do
    root "dashboard#index"
    resources :groups, path: "groupes" do
      resources :concerts, path: "concerts", only: [:new, :create, :edit, :update, :destroy]
      get "calendrier-disponibilites", to: "availability_calendars#show", as: :availability_calendar
      post "calendrier-disponibilites", to: "availability_calendars#update"
      resources :concert_availabilities, path: "disponibilites", except: [:show]
      resources :group_managers, path: "responsables", only: [:create, :destroy]
    end
  end
  namespace :admin do
    root "memberships#index"
    resources :skill_accesses, only: [:update]
    resources :memberships, only: [:index]
    resources :skills do
      resources :skill_releases, except: [:show]
    end
  end
  # Les anciens parcours réservation / Stripe ne sont pas exposés dans cette V1.
end
