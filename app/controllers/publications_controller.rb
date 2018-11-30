class PublicationsController < ApplicationController
  def index
    @publications = Publication.paginate(:page => params[:page], :per_page => 60, :order => 'name')
  end

  def show
    @publication = Publication.find(params[:id])
  end

  def new
    @publication = Publication.new
    @locations = Location.all.order("name")
    @publication_types = PublicationType.all.order("sort_order")
  end

  def create
    @locations = Location.all.order("name")
    @publication_types = PublicationType.all.order("sort_order")
    if params[:cancel_button]
      redirect_to publications_path
    else
      @publication = Publication.new(params[:publication])
      if @publication.save
        flash_message :notice, "Publication Created"
        redirect_to publications_path
      else
        flash_message :error, "Publication Creation Failed"
        render :action => :new
      end
    end    
  end
  
  def edit
    @publication = Publication.find(params[:id])
    @locations = Location.all.order("name")
    @publication_types = PublicationType.all.order("sort_order")
  end

  def update
    @locations = Location.all.order("name")
    @publication_types = PublicationType.all.order("sort_order")
    @publication = Publication.find(params[:id])
    if @publication.update_attributes(params[:publication])
      flash_message :notice, "Publication updated"
      redirect_to publications_url
    else
      render :action => :edit
    end
  end
  
  def destroy
    @publication = Publication.find(params[:id])
    if @publication.destroy
      flash_message :notice, "Publication Killed!"
      redirect_to publications_path
    else
      flash_message :error, "Publication Deletion Failed"
      redirect_to publications_path
    end
  end
end
