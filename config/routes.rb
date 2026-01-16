Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :blocks, only: [:index, :show], param: :number_or_hash
      resources :transactions, only: [:index, :show], param: :hash
      resources :addresses, only: [:show], param: :address do
        member do
          get :transactions
          get :token_transfers
        end
      end
      resources :tokens, only: [:index, :show], param: :address do
        member do
          get :transfers
        end
      end
      get :search, to: 'search#index'
    end
  end
end
