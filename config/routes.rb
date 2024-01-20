# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    post 'study_sessions/create', to: 'study_sessions#create'
    post 'study_sessions/update', to: 'study_sessions#update'
  end
  root 'static_pages#index'
  # カスタムルート
  get 'dashboard/years', to: 'dashboard#years'
  get 'dashboard/index/:year/:month', to: 'dashboard#index'
  get 'dashboard/week_data', to: 'dashboard#week_data'
  get 'static_pages/how_to_use', to: 'static_pages#how_to_use'

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
