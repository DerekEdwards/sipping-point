Rails.application.routes.draw do

  root to: 'events#index'

  devise_for :users
  
  resources :events 

  resources :rsvps do
    member do
      patch 'update'
      get 'edit'
    end
  end

end
