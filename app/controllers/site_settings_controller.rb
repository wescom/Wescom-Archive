class SiteSettingsController < ApplicationController
  before_filter :require_admin
  
  def index
    @settings = SiteSettings.find(:all)
  end
  
  def edit
    @settings = SiteSettings.find(params[:id])

    # No record exists so create the first one.
#    if !@settings.present?
#      @settings = SiteSettings.new
#      @settings.save
#      @settings = SiteSettings.find(:first)
#      Rails.logger.info "**** Created initial SiteSettings record. "
#    end
  end

  def update
    @settings = SiteSettings.find(params[:id])
    if params[:cancel_button]
      redirect_to root_url
    else
      @settings.attributes=(params[:site_settings])
      if @settings.save
        flash[:notice] = "Site Settings updated"
        redirect_to root_url
      else
        render :action => :edit
      end
    end
  end
end
