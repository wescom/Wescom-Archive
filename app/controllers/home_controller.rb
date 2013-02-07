class HomeController < ApplicationController
  before_filter :require_user

  def index
    @settings = SiteSettings.find(:first)
    if !@settings.show_site_announcement
      redirect_to search_path
    end
  end
end
