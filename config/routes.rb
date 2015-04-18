Rails.application.routes.draw do

  root to: 'events#index'

  resources :users do
    member do
      get 'new'
    end
  end

  resources :events


  resources :rsvps do
    member do
      patch 'update'
    end
    collection do
      get 'edit'
    end
  end

  devise_for :users

end
