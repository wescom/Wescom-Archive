Wescomarchive::Application.routes.draw do
  resources :papers
  resources :stories
  resources :correction_links
  resources :story_images

  resources :users, :only => [:index, :show, :edit, :update]
  resources :site_settings

  match "/home" => "home#index"
  match "/search" => "search#index"
  match "/search/today" => "search#today"

  match "/login" => "Auth#create"
  match "/logout" => "Auth#destroy"
  match "/setup" => "Auth#setup"

  root :to => "search#index"
end
