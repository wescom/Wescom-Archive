class PublicationTypesController < ApplicationController

  def index
    @publication_types = PublicationType.paginate(:page => params[:page], :per_page => 60).order('sort_order')
  end

  def show
    @publication_type = PublicationType.find(params[:id])
  end

  def new
    @publication_type = PublicationType.new
  end

  def create
    if params[:cancel_button]
      redirect_to publication_types_path
    else
      @publication_type = PublicationType.new(publication_type_params)
      if @publication_type.save
        flash_message :notice, "Publication Type Created"
        redirect_to publication_types_path
      else
        flash_message :error, "Publication Type Creation Failed"
        render :action => :new
      end
    end    
  end
  
  def edit
    @publication_type = PublicationType.find(params[:id])
  end

  def update
    @publication_type = PublicationType.find(params[:id])
    if @publication_type.update_attributes(publication_type_params)
        flash_message :notice, "Publication Type Updated"
        redirect_to publication_types_url
    else
        flash_message :error, "Publication Type Update Failed"
        render :action => :edit
    end
  end
  
  def destroy
    @publication_type = PublicationType.find(params[:id])
    if @publication_type.destroy
        flash_message :notice, "Publication Type Deleted"
        redirect_to publication_types_path
    else
        flash_message :error, "Publication Type Deletion Failed"
        redirect_to publication_types_path
    end
  end

  private
    def publication_type_params
      params.require(:publication_type).permit(:name, :sort_order)
    end
end
