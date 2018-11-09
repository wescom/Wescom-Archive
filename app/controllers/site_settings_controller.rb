class SiteSettingsController < ApplicationController
  before_action :require_admin
  
  def index
    @settings = SiteSettings.all
  end
  
  def edit
    @settings = SiteSettings.find(params[:id])
  end

  def update
    @settings = SiteSettings.find(params[:id])
    if params[:cancel_button]
      redirect_to site_settings_url
    else
      @settings.update_attributes(site_settings_params)
      if @settings.save
        flash_message :notice, "Site Settings updated"
        redirect_to site_settings_url
      else
        flash_message :error, "Site Settings update failed"
        render :action => :edit
      end
    end
  end

  private
    def site_settings_params
      params.require(:site_settings).permit(:show_delete_button, :show_site_announcement, :site_announcement)
    end
end
