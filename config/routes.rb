MockleyCrew::Engine.routes.draw do
  resource :database, only: [:create, :destroy], controller: "database" do
    resources :data, only: [:create], controller: 'database/data'
  end
end