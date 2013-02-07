class SiteSettingsController < ApplicationController
  before_filter :require_admin
  
  def index
    @settings = SiteSettings.find(:all)
  end
  
  def edit
    @settings = SiteSettings.find(params[:id])
  end

  def update
    @settings = SiteSettings.find(params[:id])
    if params[:cancel_button]
      redirect_to site_settings_url
    else
      @settings.attributes=(params[:site_settings])
      if @settings.save
        flash[:notice] = "Site Settings updated"
        redirect_to site_settings_url
      else
        render :action => :edit
      end
    end
  end
end
