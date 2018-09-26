class HomeController < ApplicationController
  before_action :require_user

  def index
    @settings = SiteSettings.first
    if !@settings.show_site_announcement
      redirect_to search_path
    end
  end
end
