TrustCrowd::Application.routes.draw do

  resources :problems do
    get :active,              :on => :member
    get :close,               :on => :member
    get :search,              :on => :collection
    get :participate,         :on => :member
    get :evaluate,            :on => :member
    get :evaluate_criteria,   :on => :member
    get :finish_evaluation,   :on => :member
    resources :alternatives do
      get :rejected, :on => :collection
      get :active,   :on => :member
    end
    
    resources :criteria do
      get :rejected,  :on => :collection
      get :active,    :on => :member
      
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
  
  get "/" => 'home#index'
end
