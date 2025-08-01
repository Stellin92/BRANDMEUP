Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:edit, :update]
  resources :outfits
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get "guide", to: "pages#guide"
  get "users/edit", to: "users#edit"
  get "users/:id", to: "users#show"
  patch "users/update", to: "users#update"
  get "outfits/new", to: "outfits#new"
  post "outfits", to: "outfits#create"
  get "outfits/:id", to: "outfits#show"
  patch "outfit/:id/update", to: "outfits#update"
  get "validation", to: "pages#validation"

end
