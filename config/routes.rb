require "sidekiq/web"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  mount Sidekiq::Web => "/sidekiq"

  post "admin/sign_in", to: "admin#create"
  delete "admin/sign_out", to: "admin#destroy"

  namespace :admin do
    scope :user do
      resources :sign_up, only: [ :index, :create ]
    end
    namespace :password do
      resources :recovery, only: [ :index, :create ]
      resources :reset, only: [ :index, :create ]
    end
  end

  resources :admin, param: :account_reference, only: [ :index, :show ] do
    resources :roles, controller: "admin/roles", except: [ :show ]
    resources :users, controller: "admin/users", except: [ :show ]
  end
end
