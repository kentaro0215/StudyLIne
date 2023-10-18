Rails.application.routes.draw do
  # get 'dashboard/top_page'
  # get 'dashboard/after_login'
  root "dashboard#top_page" 
  get "dashboard/after_login", to: "dashboard#after_login"
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks',sessions: 'users/sessions' }
  devise_scope :user do
    delete 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
