Rails.application.routes.draw do

  root to: 'events#index'

  devise_for :users 
  
  resources :users do
    member do
      get 'events'
      get 'hidden_events'
    end
  end 
  
  resources :events 

  resources :events do 
    member do
      get 'caltest'
      get 'report'
      patch 'report', action: 'update_report'
    end
  end

  resources :comments do
    member do
      patch 'create'
      delete 'delete'
      patch 'update'
    end
  end

  resources :rsvps do
    member do
      patch 'update'
      get   'edit'
      patch 'update_email_comments_setting'
      get   'rsvp_reminder'
      get   'turn_off_comments'
      patch 'hide'
      patch 'unhide'
    end
  end

  namespace :admin do
    resources :events
  end

end
