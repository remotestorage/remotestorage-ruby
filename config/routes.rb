RemoteStorage::Application.routes.draw do

  get '/.well-known/host-meta', :to => 'webfinger#host_meta', :as => :webfinger

  resource :session

  resources :users
  resources :authorizations

  match '/storage/*path', :to => 'application#cors_allow', :via => :options
  match '/.well-known/host-meta', :to => 'application#cors_allow', :via => :options

  get "/storage/:user/(*path)", :to => 'nodes#get', :as => :node
  put "/storage/:user/(*path)", :to => 'nodes#put'
  delete "/storage/:user/*path", :to => 'nodes#delete'

  get '/dashboard', :to => 'dashboard#index'
  get '/dashboard/:action', :to => 'dashboard'

  root :to => 'root#index'


end
