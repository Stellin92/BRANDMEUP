Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:show, :edit, :update]
  resources :outfits do
    resources :feedbacks, only: [:new, :create, :show, :edit, :update]
  end

  resources :feedbacks, only: [:show, :edit, :update, :destroy]

  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get "guide", to: "pages#guide"
  get "validation", to: "pages#validation"

end
