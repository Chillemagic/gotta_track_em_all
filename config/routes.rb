Rails.application.routes.draw do
  resources :collection_cards
  mount ActionCable.server => "/cable"
  get "tracker/index"
  get "tracker/show"
  get "/check_username", to: "users#check_username"

  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :trackers, only: %i[index show]
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"

  # collections routes
  resources :collections

  # cards routes
  resources :cards, only: [ :index, :show ] do
    # member refers to an individual card
    member do
      get "price_history"
      post :simulate_price
    end
    # collection refers to all cards
    collection do
      get "search"
      post "search"
    end
  end
end

# LINK TO ROUTES:

# 1. Link to all collections:
# <%= link_to "My Collections", collections_path %>

# 2. Link to specific collection:
# <%= link_to @collection.name, collection_path(@collection) %>

# 3. Link to new collection form:
# <%= link_to "New Collection", new_collection_path %>

# 4. Link to edit collection:
# <%= link_to "Edit", edit_collection_path(@collection) %>

# 5. Link to card details:
# <%= link_to card.name, card_path(card) %>
