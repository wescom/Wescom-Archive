Wescomarchive::Application.routes.draw do
  resources :locations
  resources :publications
  resources :publication_types
  resources :plans do
    get 'publications_and_section_options', :on => :collection
  end
  resources :papers
  resources :sections
  resources :section_categories
  resources :stories
  resources :correction_links
  resources :story_images
  resources :pdf_images do
    get 'book', :on => :collection
  end

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
