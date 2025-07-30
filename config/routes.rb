Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get "register", to: "pages#register"
  get "guide", to: "pages#guide"
  get "users/:id/edit", to: "users#edit"
  get "users/:id", to: "users#show"
  patch "users/:id/update", to: "users#update"
  get "outfit/new", to: "outfits#new"
  post "outfit", to: "outfits#create"
  patch "outfit/:id/update", to: "outfits#update"
  get "outfit/:id", to: "outfits#show"
  get "validation", to: "pages#validation"

end
