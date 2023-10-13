Rails.application.routes.draw do
  devise_for :users
  # get 'dashboard/top_page'
  # get 'dashboard/after_login'
  root "dashboard#top_page" 
  get "dashboard/after_login", to: "dashboard#after_login"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
