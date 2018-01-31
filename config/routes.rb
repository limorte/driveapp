Rails.application.routes.draw do
  get 'welcome/index'
 
  root 'posts#index'
  resources :posts
end