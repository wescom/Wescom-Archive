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
      @location = Location.new(params[:location])
      if @location.save
        flash[:notice] = "Location Created"
        redirect_to locations_path
      else
        flash[:error] = "Location Creation Failed"
        render :action => :new
      end
    end    
  end
  
  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice] = "Location updated"
      redirect_to locations_url
    else
      render :action => :edit
    end
  end
  
  def destroy
    @location = Location.find(params[:id])
    if @location.destroy
      flash[:notice] = "Location Killed!"
      redirect_to locations_path
    else
      flash[:error] = "Location Deletion Failed"
      redirect_to locations_path
    end
  end

end
