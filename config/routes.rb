Rails.application.routes.draw do

  root to: 'events#index'

  devise_for :users 
  
  resources :users do
    member do
      get 'events'
    end
  end 
  
  resources :events 

  resources :events do 
    member do
      get 'caltest'
    end
  end

  resources :comments do
    member do
      patch 'create'
    end
  end

  resources :rsvps do
    member do
      patch 'update'
      get 'edit'
    end
  end

end
