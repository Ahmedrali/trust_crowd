TrustCrowd::Application.routes.draw do

  resources :problems do
    get :active,    :on => :member
    get :close,     :on => :member
    get :search,    :on => :collection
    get :participate,     :on => :member
    resources :alternatives do
      get :rejected, :on => :collection
      get :active,   :on => :member
    end
    
    resources :criteria do
      get :rejected, :on => :collection
      get :active,   :on => :member
    end  
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  
  authenticated :user do
    root :to => 'users#index'
  end
  
  get "/" => 'home#index'
end
