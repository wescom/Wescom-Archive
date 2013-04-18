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
    @pdfs = @plan.pdf_images.order('page')
    @stories = @plan.stories.order('page')
  end

  def update
    @plan = Plan.find(params[:id])
    @locations = Location.find(:all, :order => "name")
    @publication_types = PublicationType.find(:all, :order => "sort_order")
    @pdfs = @plan.pdf_images.order('page')
    @stories = @plan.stories.order('page')
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
  
  def pubs_for_pub_type_and_location
    scope = Plan.select(:pub_name).where("pub_name is not null and pub_name<>''")
    if !(params[:location].nil? or params[:location] == "")
      scope = scope.where(:location_id => params[:location])
    end
    if !(params[:pub_type].nil? or params[:pub_type] == "")
      scope = scope.where(:publication_type_id => params[:pub_type])
    end
    scope = scope.uniq.order('pub_name')
    #Rails.logger.info @publications.to_yaml

    respond_to do |format|
      format.html
      format.json  { render :json => scope }
    end
  end
end
