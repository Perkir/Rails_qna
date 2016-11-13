# frozen_string_literal: true
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :questions, only: [:new, :create, :index, :show] do
    resources :answers, only: [:new, :create]
  end
end