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

  # Organization
  resources :bookmarks, only: %i[index create destroy]
  resources :highlights, only: %i[create destroy]
  resources :annotations, only: %i[index create update destroy]
  resources :collections, only: %i[index show create update destroy] do
    member do
      post :add_passage
      delete :remove_passage
    end
  end

  # Study tools
  resources :parallel_passages, only: :create
  get "word_study/:passage_id/:position", to: "word_studies#show", as: :word_study
  get "concordance/:id", to: "word_studies#concordance", as: :concordance

  # Search & jump-to-reference
  get "search", to: "search#index", as: :search
  get "jump", to: "passages#jump", as: :jump

  # Canonical passage URLs: /bible/genesis/1
  get ":corpus_slug/:scripture_slug/:division_number", to: "passages#show", as: :reading

  # Root: show the default reading view (Genesis 1)
  root "passages#show"
end
