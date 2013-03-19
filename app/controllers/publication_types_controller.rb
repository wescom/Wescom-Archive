class PublicationTypesController < ApplicationController

  def index
    @publication_types = PublicationType.paginate(:page => params[:page], :per_page => 60, :order => 'name')
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
      @publication_type = PublicationType.new(params[:publication_type])
      if @publication_type.save
        flash[:notice] = "Publication Type Created"
        redirect_to publication_types_path
      else
        flash[:error] = "Publication Type Creation Failed"
        render :action => :new
      end
    end    
  end
  
  def edit
    @publication_type = PublicationType.find(params[:id])
  end

  def update
    @publication_type = PublicationType.find(params[:id])
    if @publication_type.update_attributes(params[:publication_type])
      flash[:notice] = "Publication Type updated"
      redirect_to publication_types_url
    else
      render :action => :edit
    end
  end
  
  def destroy
    @publication_type = PublicationType.find(params[:id])
    if @publication_type.destroy
      flash[:notice] = "Publication Type Killed!"
      redirect_to publication_types_path
    else
      flash[:error] = "Publication Type Deletion Failed"
      redirect_to publication_types_path
    end
  end

end
