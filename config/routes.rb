Rails.application.routes.draw do

  devise_for :users, controllers: {
                       registrations: 'users/registrations',
                       sessions: 'users/sessions',
                       confirmations: 'users/confirmations',
                       omniauth_callbacks: 'users/omniauth_callbacks'
                     }
  devise_for :organizations, class_name: 'User',
             controllers: {
               registrations: 'organizations/registrations',
               sessions: 'devise/sessions',
             },
             skip: [:omniauth_callbacks]

  devise_scope :organization do
    get 'organizations/sign_up/success', to: 'organizations/registrations#success'
  end

  devise_scope :user do
    patch '/user/confirmation', to: 'users/confirmations#update', as: :update_user_confirmation
    get '/user/registrations/check_username', to: 'users/registrations#check_username'
    get 'users/sign_up/success', to: 'users/registrations#success'
    get 'users/registrations/delete_form', to: 'users/registrations#delete_form'
    delete 'users/registrations', to: 'users/registrations#delete'
    get :finish_signup, to: 'users/registrations#finish_signup'
    patch :do_finish_signup, to: 'users/registrations#do_finish_signup'
  end

  root 'welcome#index'
  get '/welcome', to: 'welcome#welcome'
  get '/cuentasegura', to: 'welcome#verification', as: :cuentasegura

  resources :debates do
    member do
      post :vote
      put :flag
      put :unflag
      put :mark_featured
      put :unmark_featured
    end
    collection do
      get :map
      get :suggest
    end
  end

  resources :answers, only: [:index, :new, :create]

  resources :proposals do
    member do
      post :vote
      post :vote_featured
      put :flag
      put :unflag
      get :retire_form
      patch :retire
    end
    collection do
      get :map
      get :suggest
      get :summary
    end
  end

  resources :proposal_ballots, only: [:index]

  resources :comments, only: [:create, :show], shallow: true do
    member do
      post :vote
      put :flag
      put :unflag
    end
  end

  get 'presupuestos/faq',     to: 'pages#show', id: 'budgets/faq',      as: 'budgets_faq'
  get 'presupuestos',         to: 'pages#show', id: 'budgets/welcome',  as: 'budgets_welcome'
  get 'participatory_budget', to: 'pages#show', id: 'budgets/welcome',  as: 'participatory_budget'
  get 'participatory_budget/in_two_minutes', to: 'pages#show', id: 'budgets/welcome'
  resources :budgets, only: [:show, :index], path: 'presupuestos' do
    resources :groups, controller: "budgets/groups", only: [:show], path: 'grupo'
    resources :investments, controller: "budgets/investments", only: [:index, :show, :new, :create, :destroy], path: 'proyecto' do
      member { post :vote }
    end
    resource :ballot, only: :show, controller: "budgets/ballots" do
      resources :lines, controller: "budgets/ballot/lines", only: [:create, :destroy]
    end
  end
  get "presupuestos/:budget_id/:id/:heading_id", to: "budgets/investments#index", as: 'custom_budget_investments'
  get "presupuestos/:budget_id/:id", to: "budgets/groups#show", as: 'custom_budget_group'

  scope '/participatory_budget' do
    resources :spending_proposals, only: [:index, :show, :destroy], path: 'investment_projects' do #[:new, :create] temporary disabled
      get :welcome, on: :collection
      get :stats, on: :collection
      post :vote, on: :member
    end

    resource :ballot, only: [:show] do
      resources :ballot_lines, only: [:create, :destroy], shallow: true
    end

  end

  resources :open_plenaries, only: [] do
    get :results, on: :collection
  end

  resources :stats, only: [:index]

  resources :legislations, only: [:show]

  resources :annotations do
    get :search, on: :collection
  end

  resources :users, only: [:show] do
    resources :direct_messages, only: [:new, :create, :show]
  end

  resource :account, controller: "account", only: [:show, :update, :delete] do
    get :erase, on: :collection
  end

  resources :notifications, only: [:index, :show] do
    put :mark_all_as_read, on: :collection
  end

  resources :proposal_notifications, only: [:new, :create, :show]

  resource :verification, controller: "verification", only: [:show]

  scope module: :verification do
    resource :residence, controller: "residence", only: [:new, :create]
    resource :sms, controller: "sms", only: [:new, :create, :edit, :update]
    resource :verified_user, controller: "verified_user", only: [:show]
    resource :email, controller: "email", only: [:new, :show, :create]
    resource :letter, controller: "letter", only: [:new, :create, :show, :edit, :update]
  end
  get "/verifica", to: "verification/letter#edit"

  namespace :admin do
    root to: "dashboard#index"
    resources :organizations, only: :index do
      get :search, on: :collection
      member do
        put :verify
        put :reject
      end
    end

    resources :users, only: [:index, :show] do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :debates, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :proposals, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :spending_proposals, only: [:index, :show, :edit, :update] do
      member do
        patch :assign_admin
        patch :assign_valuators
      end

      get :summary, on: :collection
      get :results, on: :collection
    end

    resources :probes, only: [:index, :show]

    resources :budgets do
      resources :budget_groups do
        resources :budget_headings do
        end
      end

      resources :budget_investments, only: [:index, :show, :edit, :update] do
        member { patch :toggle_selection }
      end
    end

    resources :signature_sheets, only: [:index, :new, :create, :show]

    resources :banners, only: [:index, :new, :create, :edit, :update, :destroy] do
      collection { get :search}
    end

    resources :comments, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :tags, only: [:index, :create, :update, :destroy]
    resources :officials, only: [:index, :edit, :update, :destroy] do
      get :search, on: :collection
    end

    resources :settings, only: [:index, :update]
    resources :moderators, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end

    resources :valuators, only: [:index, :create] do
      get :search, on: :collection
      get :summary, on: :collection
    end

    resources :managers, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end

    resources :verifications, controller: :verifications, only: :index do
      get :search, on: :collection
    end

    resource :activity, controller: :activity, only: :show
    resources :newsletters, only: :index do
      get :users, on: :collection
    end

    resource :stats, only: :show do
      get :spending_proposals, on: :collection
      get :graph, on: :member
      get :proposal_notifications, on: :collection
      get :direct_messages, on: :collection
      get :redeemable_codes, on: :collection
      get :user_invites, on: :collection
    end

    namespace :api do
      resource :stats, only: :show
    end

    resources :geozones, only: [:index, :new, :create, :edit, :update, :destroy]
  end

  namespace :moderation do
    root to: "dashboard#index"

    resources :users, only: :index do
      member do
        put :hide
        put :hide_in_moderation_screen
      end
    end

    resources :debates, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end

    resources :proposals, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end

    resources :comments, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end
  end

  namespace :valuation do
    root to: "budgets#index"

    resources :spending_proposals, only: [:index, :show, :edit] do
      patch :valuate, on: :member
    end

    resources :budgets, only: :index do
      resources :budget_investments, only: [:index, :show, :edit] do
        patch :valuate, on: :member
      end
    end
  end

  namespace :management do
    root to: "dashboard#index"

    resources :document_verifications, only: [:index, :new, :create] do
      post :check, on: :collection
    end

    resources :email_verifications, only: [:new, :create]

    resources :user_invites, only: [:new, :create]

    resources :users, only: [:new, :create] do
      collection do
        delete :logout
        delete :erase
      end
    end

    resource :account, controller: "account", only: [:show]

    get 'sign_in', to: 'sessions#create', as: :sign_in

    resource :session, only: [:create, :destroy]
    resources :proposals, only: [:index, :new, :create, :show] do
      post :vote, on: :member
      get :print, on: :collection
    end

    resources :spending_proposals, only: [:index, :show] do #[:new, :create] temporary disabled
      post :vote, on: :member
      get :print, on: :collection
    end

    resources :budgets, only: :index do
      collection do
        get :create_investments
        get :support_investments
        get :print_investments
      end
      resources :investments, only: [:index, :new, :create, :show], controller: 'budgets/investments' do
        post :vote, on: :member
        get :print, on: :collection
      end
    end
  end

  resources :forums, only: [:index, :create, :show]
  resources :representatives, only: [:create, :destroy]

  resources :probes, only: [:show] do
    post :selection,  on: :collection
    get :thanks, on: :collection

    resources :probe_options, only: :show do
      post :discard, on: :member
      post :restore_discarded, on: :collection
    end
  end

  resources :human_rights, only: [:index, :show]

  resource :volunteer_poll, only: [:new, :create] do
    get :thanks, on: :collection
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount Tolk::Engine => '/translate', :as => 'tolk'

  get 'voluntarios-mesas-presenciales' => redirect('/volunteer_poll/new')
  get 'encuesta-plaza-espana' => redirect('/encuesta-plaza-espana-resultados')
  get '/blog' => redirect('http://diario.madrid.es/decidemadrid/')
  get 'participatory_budget/select_district', to: 'spending_proposals#select_district', as: 'select_district'
  get 'delegacion', to: 'forums#index', as: 'delegation'
  get 'plenoabierto', to: 'pages#show', id: 'processes_open_plenary'
  get 'noticias', to: 'pages#show', id: 'news'
  get 'presupuestos-participativos-resultados', to: 'spending_proposals#results', as: 'participatory_budget_results'
  get 'presupuestos-participativos-estadisticas', to: 'spending_proposals#stats', as: 'participatory_budget_stats'
  #get 'vota', to: 'proposal_ballots#index', as: 'proposal_ballots_index'

  #Probes
  get 'processes/urbanismo-bancos', to: 'probes#show', id: 'town_planning', as: 'town_planning'
  get 'processes/urbanismo-bancos-gracias', to: 'probes#thanks', id: 'town_planning', as: 'town_planning_thanks'
  get 'proceso/plaza-espana-resultados', to: 'probes#show', id: 'plaza', as: 'plaza'
  get 'proceso/plaza-espana',            to: 'probes#show', id: 'plaza'
  get 'proceso/plaza-espana-gracias', to: 'probes#thanks', id: 'plaza', as: 'plaza_thanks'
  get 'proceso/plaza-espana/proyectos/:id', to: 'probe_options#show', probe_id: 'plaza', as: 'plaza_probe_option'

  get 'proceso/plaza-espana-informacion',  to: 'pages#show',   id: 'processes_plaza_espana',            as: 'remodeling_plaza'
  get 'proceso/plaza-espana-estadisticas', to: 'pages#show',   id: 'encuesta-plaza-espana-resultados',  as: 'survey_plaza'

  #Human Rights
  get 'derechos-humanos',                  to: 'pages#show', id: 'processes/human_rights',      as: 'human_rights_page'
  get 'derechos-humanos/plan',             to: 'pages#show', id: 'processes/human_rights_plan', as: 'human_rights_plan'
  get 'derechos-humanos/medidas',          to: 'human_rights#index',                            as: 'human_rights_proposals'
  get 'derechos-humanos/medidas/:id',      to: 'human_rights#show',                             as: 'human_rights_proposal'

  get 'processes/human_rights_question_1', to: 'pages#show', id: 'processes/human_rights_question_1'
  get 'processes/human_rights_question_2', to: 'pages#show', id: 'processes/human_rights_question_2'
  get 'processes/human_rights_question_3', to: 'pages#show', id: 'processes/human_rights_question_3'

  #Processes
  get 'procesos',                                   to: 'pages#show', id: 'processes',                        as: 'processes'
  get 'proceso/licencias-urbanisticas',             to: 'pages#show', id: 'processes/urbanistic_licenses',    as: 'urbanistic_licenses'
  get 'proceso/alianza-gobierno-abierto',           to: 'pages#show', id: 'processes/open_government',        as: 'open_government'
  get 'proceso/alianza-gobierno-abierto-borrador',  to: 'pages#show', id: 'processes/open_government_doc',    as: 'open_government_doc'
  get 'proceso/ordenanza-subvenciones',             to: 'pages#show', id: 'processes/subvention_ordinance',   as: 'subvention_ordinance'
  get 'proceso/plan-calidad-aire',                  to: 'pages#show', id: 'processes/air_quality_plan/index', as: 'air_quality_plan'
  get 'proceso/rotulacion-vias',                    to: 'pages#show', id: 'processes/label_streets/index',    as: 'label_streets'
  get 'proceso/distrito-villa-de-vallecas',         to: 'pages#show', id: 'processes/vallecas/index',         as: 'vallecas'

  #Budgets meetings
  get 'budgets/meetings/2016', to: 'pages#show', id: 'budgets/meetings/2016', as: 'budgets_meetings_2016'
  get 'budgets/meetings/2017', to: 'pages#show', id: 'budgets/meetings/2017', as: 'budgets_meetings_2017'

  #Campaña Blas Bonilla
  get 'haz-propuestas',                             to: 'pages#show', id: 'blas_bonilla', as: 'blas_bonilla'

  #Landings
  get 'vota',  to: 'pages#show', id: 'landings/first_voting', as: 'first_voting'
  get 'g1000', to: 'pages#show', id: 'landings/g1000',        as: 'g1000'

  resources :pages, path: '/', only: [:show]
end
