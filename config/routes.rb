TrustCrowd::Application.routes.draw do

  resources :problems do
    get :active,              :on => :member
    get :close,               :on => :member
    get :search,              :on => :collection
    get :participate,         :on => :member
    get :evaluate,            :on => :member
    get :evaluate_criteria,   :on => :member
    get :finish_evaluation,   :on => :member
    resources :trusts do
        post "/trust/:user_id" => 'trusts#trust', :on => :collection
        delete "/untrust/:user_id" => 'trusts#untrust', :on => :collection
        post "/delegate/:user_id" => 'trusts#delegate', :on => :collection
        post "/undelegate/:user_id" => 'trusts#undelegate', :on => :collection
    end
    resources :alternatives do
      get :rejected, :on => :collection
      get :active,   :on => :member
    end
    
    resources :criteria do
      get :pending,       :on => :collection
      get :rejected,      :on => :collection
      get :active,        :on => :member
      get :finish_voting, :on => :member
      get "vote/:decision" => "criteria#vote", :on => :member
      
      resources :evaluations do
        get :get, :on => :collection
        post :save, :on => :collection
      end
      
      resources :criteria_evaluations do
        get :get, :on => :collection
        post :save, :on => :collection
      end
      
    end
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  
  authenticated :user do
    root :to => 'users#index'
  end
  
  get "/indv" => 'decisions#getIndividual'
  get "/coll" => 'decisions#getCollectiveDecision'
  get '/u_sat' =>  'decisions#user_satisfactory'
  get '/g_sat' =>  'decisions#group_satisfactory'
  
  get "/" => 'home#index'
  
end
