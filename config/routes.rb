Rails.application.routes.draw do

  root to: 'events#index'

  resources :users do
    member do
      get 'new'
    end
  end
  resources :events do
    resources :rsvps, shallow: true
  end

  devise_for :users

end
