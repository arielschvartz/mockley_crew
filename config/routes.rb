MockleyCrew::Engine.routes.draw do
  scope 'mockley', module: 'mockley_crew' do
    resource :database, only: [:create, :destroy], controller: 'database', as: :mockley_database do
      resources :data, only: [:create], controller: 'database/data'
    end
  end
end