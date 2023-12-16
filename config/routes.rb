# frozen_string_literal: true

Rails.application.routes.draw do
  root 'dashboard#top_page'

  # カスタムルート
  get 'dashboard/after_login', to: 'dashboard#after_login'
  get 'dashboard/after_login/:year/:month', to: 'dashboard#after_login', as: 'after_login_data'
  post 'dashboard/start', to: 'dashboard#start'
  post 'dashboard/finish', to: 'dashboard#finish'
  get 'dashboard/week_data', to: 'dashboard#week_data'
  get 'dashboard/how_to_use', to: 'dashboard#how_to_use'

  # RESTfulリソース

  resources :dashboard do
    resources :tags, only: %i[create destroy]
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions' }
  devise_scope :user do
    delete 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
