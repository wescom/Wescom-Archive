class PlansController < ApplicationController
  def index
    @plans = Plan.paginate(:page => params[:page], :per_page => 60).order_by_location_type_pub_section
  end

  def show
    @plan = Plan.find(params[:id])
  end

  def edit
    @plan = Plan.find(params[:id])
    @locations = Location.find(:all, :order => "name")
    @publication_types = PublicationType.find(:all, :order => "sort_order")
  end

  def update
    @plan = Plan.find(params[:id])
    @locations = Location.find(:all, :order => "name")
    @publication_types = PublicationType.find(:all, :order => "sort_order")
    if params[:cancel_button]
      redirect_to plans_path
    else
      if @plan.update_attributes(params[:plan])
        flash[:notice] = "Plan updated"
        redirect_to plans_url
      else
        render :action => :edit
      end
    end
  end
  
  def destroy
    @plan = Plan.find(params[:id])
    if @plan.destroy
      flash[:notice] = "Plan Killed!"
      redirect_to plans_path
    else
      flash[:error] = "Plan Deletion Failed"
      redirect_to plans_path
    end
  end
end
