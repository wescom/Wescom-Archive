Wescomarchive::Application.routes.draw do
  resources :papers
  resources :stories
  resources :correction_links

  match "/home" => "home#index"
  match "/search" => "search#index"
  match "/search/today" => "search#today"

  root :to => "search#index"
end
