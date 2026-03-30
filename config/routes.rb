Rails.application.routes.draw do
  # Authentication
  resource :session, only: %i[new create destroy]
  resource :session_verification, only: %i[show create], controller: "sessions/verifications"
  get "session/magic_token", to: "sessions/magic_tokens#show", as: :session_magic_token
  resource :account, only: %i[show update]
  resources :passkey_credentials, only: %i[create destroy]
  namespace :passkey_credentials do
    resource :options, only: %i[show create]
    resource :authentication, only: :create
  end

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
  namespace :annotations do
    resource :export, only: :show
    resource :import, only: :create
    get "shared/:user_id", to: "shared#show", as: :shared
  end
  namespace :collections do
    resources :passages, only: %i[create destroy]
  end
  resources :collections, only: %i[index show create update destroy]

  # Groups & collaboration
  resources :groups, only: %i[index show new create edit update destroy] do
    resources :invitations, only: :create, module: :groups
    resource :membership, only: :destroy, module: :groups
  end
  get "groups/invitations/:token", to: "groups/invitations#show", as: :group_invitation_accept
  resources :annotation_comments, only: %i[create destroy]

  # Research tools
  namespace :curricula do
    resources :passages, only: %i[create destroy]
    resource :positions, only: :update
    resources :read_progresses, only: %i[create destroy]
    resource :export, only: :show
  end
  resources :curricula, only: %i[index show new create edit update destroy]
  namespace :reading_progresses do
    resource :time, only: :create
  end
  resources :reading_progresses, only: :create
  delete "reading_progress", to: "reading_progresses#destroy", as: :reading_progress

  # Study tools
  resources :parallel_passages, only: :create
  resources :ratings, only: :create
  get "word_study/:passage_id/:position", to: "word_studies#show", as: :word_study
  resources :concordances, only: :show

  # Export (collection route must come before passages to avoid slug matching)
  get "export/collection/:id", to: "exports#collection", as: :export_collection
  get "export/:corpus_slug/:scripture_slug", to: "exports#passages", as: :export_passages

  # Discovery & statistics
  namespace :discover do
    resource :stats, only: :show
    resource :word_frequency, only: :show
    resource :exploration, only: :show
  end
  get "discover", to: "discover#index", as: :discover

  # Search & jump-to-reference
  get "search", to: "search#index", as: :search
  resource :jump, only: :show

  namespace :admin do
    root "dashboard#index"
    get "countries", to: "countries#index"

    # Content
    resources :traditions
    resources :corpora
    resources :scriptures
    resources :translations

    # Scholarship
    resources :commentaries
    resources :source_documents
    resources :lexicon_entries
    resources :manuscripts
    resources :featured_passages

    # Community
    resources :users
    resources :groups
    resources :annotations

    # Imports
    get "imports", to: "imports#index", as: :imports
    post "imports/download", to: "imports#download", as: :imports_download
    post "imports/run", to: "imports#run", as: :imports_run
    post "imports/run_all", to: "imports#run_all", as: :imports_run_all
  end

  # Canonical passage URLs: /bible/genesis/1
  # Must be after all other routes to avoid catching /admin/* etc.
  get ":corpus_slug/:scripture_slug/:division_number", to: "passages#show", as: :reading

  # Landing page
  root "pages#home"
end
