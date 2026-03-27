Rails.application.routes.draw do
  # Authentication
  resource :session, only: %i[new create destroy] do
    get "magic_token", on: :member
  end
  resource :account, only: %i[show update]
  resources :passkey_credentials, only: %i[create destroy] do
    collection do
      post :options_for_create
      post :options_for_authenticate
    end
  end
  post "passkey_authenticate", to: "passkey_credentials#authenticate"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Browse traditions and corpora
  resources :traditions, only: [ :index, :show ] do
    resources :corpora, only: [ :show ], param: :slug
  end

  # Search
  get "search", to: "search#index", as: :search

  # Canonical passage URLs: /bible/genesis/1
  get ":corpus_slug/:scripture_slug/:division_number", to: "passages#show", as: :reading

  # Root: show the default reading view (Genesis 1)
  root "passages#show"
end
