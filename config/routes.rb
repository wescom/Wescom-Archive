Wescomarchive::Application.routes.draw do
  resources :papers
  resources :sections
  resources :section_categories
  resources :stories
  resources :correction_links
  resources :story_images

  resources :users, :only => [:index, :show, :edit, :update]
  resources :site_settings, :only => [:index, :edit, :update]

  match "/home" => "home#index"
  match "/search" => "search#index"
  match "/search/today" => "search#today"
  match "/search_images" => "story_images#search"

  match "/login" => "Auth#create"
  match "/logout" => "Auth#destroy"
  match "/setup" => "Auth#setup"

  root :to => "home#index"
end
