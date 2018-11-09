class LocationsController < ApplicationController

  def index
    @locations = Location.paginate(:page => params[:page], :per_page => 60).order_by_location_type_pub_section
  end

  def show
    @location = Location.find(params[:id])
  end

  def new
    @location = Location.new
  end

  def create
    if params[:cancel_button]
      redirect_to locations_path
    else
      @location = Location.new(location_params)
      if @location.save
        flash_message :notice, "Location Created"
        redirect_to locations_path
      else
        flash_message :error, "Location Creation Failed"
        render :action => :new
      end
    end    
  end
  
  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])
    if @location.update_attributes(location_params)
        flash_message :notice, "Location Updated"
        redirect_to locations_path
    else
        flash_message :error, "Location Update Failed"
        render :action => :edit
    end
  end
  
  def destroy
    @location = Location.find(params[:id])
    if @location.destroy
        flash_message :notice, "Location Killed!"
        redirect_to locations_path
    else
        flash_message :error, "Location Deletion Failed"
        redirect_to locations_path
    end
  end

  private
    def location_params
      params.require(:location).permit(:name)
    end
end
