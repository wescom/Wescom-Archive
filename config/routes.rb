Rails.application.routes.draw do

    get 'home/index'
    
    resources :locations
    resources :publications
    resources :publication_types
    resources :plans do
      get 'publications_and_section_options', :on => :collection
    end
    resources :papers
    resources :sections
    resources :section_categories
    resources :stories do
      put 'approve'
      put 'import_to_DTI'
    end
    resources :correction_links
    resources :story_images
    resources :pdf_images do
      get 'book', :on => :collection
    end
    resources :ads

    resources :users, :only => [:index, :show, :edit, :update]
    resources :site_settings, :only => [:index, :edit, :update]

    match "/home" => "home#index", :via => [:get, :post]
    match "/search" => "search#index", :via => [:get, :post]
    match "/search/today" => "search#today", :via => [:get, :post]
    match "/search_images" => "story_images#search", :via => [:get, :post]

    # Auth Routes
    resources :sessions
    match "/login" => "sessions#new", :via => [:get, :post]
    match "/logout" => "sessions#destroy", :via => [:get, :post]
    match "/adauth" => "sessions#create", :via => [:get, :post]
    match "/admin" => "sessions#new", :via => [:get, :post]
    match "/signout" => "sessions#destroy", :via => [:get, :post]

    root 'home#index'
  end