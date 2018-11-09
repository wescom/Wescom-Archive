class PlansController < ApplicationController
  def index
    @plans = Plan.paginate(:page => params[:page], :per_page => 60).order_by_location_type_pub_section
  end

  def show
    @plan = Plan.find(params[:id])
    @logs = @plan.logs.all.order('created_at DESC')
    @last_updated = @logs.first
  end

  def new
    @plan = Plan.new
    @locations = Location.all.order("name")
    @publication_types = PublicationType.all.order("sort_order")
  end

  def create
    @locations = Location.all.order("name")
    @publication_types = PublicationType.all.order("sort_order")
    if params[:cancel_button]
      redirect_to plans_path
    else
      @plan = Plan.new(plan_params)
      if @plan.save
        flash_message :notice, "Plan Created"
        redirect_to plans_path
      else
        flash_message :error, "Plan Creation Failed"
        render :action => :new
      end
    end    
  end
  
  def edit
    @plan = Plan.find(params[:id])
    @logs = @plan.logs.all.order('created_at DESC')
    @last_updated = @logs.first
    @locations = Location.all.order("name")
    @publication_types = PublicationType.all.order("sort_order")
    @pdfs = @plan.pdf_images.limit(50).order('page')
    @stories = @plan.stories.limit(50).order('page')
  end

  def update
    @plan = Plan.find(params[:id])
    @locations = Location.all.order("name")
    @publication_types = PublicationType.all.order("sort_order")
#    @pdfs = @plan.pdf_images.limit(50).order('page')
#    @stories = @plan.stories.limit(50).order('page')
    if params[:cancel_button]
      redirect_to plans_path
    else
      if @plan.update_attributes(plan_params)
#        Log.create_log("Plan",@plan.id,"Updated","Plan edited",current_user)
        flash_message :notice, "Plan updated"
        redirect_to plans_url
      else
        flash_message :error, "Plan update failed"
        render :action => :edit
      end
    end
  end
  
  def destroy
    @plan = Plan.find(params[:id])
    if @plan.destroy
        flash_message :notice, "Plan Killed!"
        redirect_to plans_path
    else
        flash_message :error, "Plan Deletion Failed"
        redirect_to plans_path
    end
  end
  
  def publications_and_section_options
    publications = Plan.where("pub_name is not null and pub_name<>''")
    publications = publications.where(:location_id => params[:location]) if params[:location].present?
    publications = publications.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    publications = publications.where(:pub_name => params[:pub_select]) if params[:pub_select].present?
    publications = publications.select("DISTINCT pub_name").uniq.order('pub_name')

    sections = Plan.where("section_name is not null and section_name<>''")
    sections = sections.where(:location_id => params[:location]) if params[:location].present?
    sections = sections.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    sections = sections.where(:pub_name => params[:pub_select]) if params[:pub_select].present?
    sections = sections.select("DISTINCT section_name").uniq.order('section_name')

    respond_to do |format|
      format.html
      format.json  { render :json => {:publications => publications, :sections => sections} }
    end
  end

  private
    def plan_params
      params.require(:plan).permit(:location_id, :publication_type_id, :import_pub_name, :import_section_name, :import_section_letter, 
          :pub_name, :section_name)
    end
end
