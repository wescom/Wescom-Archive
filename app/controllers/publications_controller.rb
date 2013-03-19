class PublicationsController < ApplicationController
  def index
    @publications = Publication.paginate(:page => params[:page], :per_page => 60, :order => 'name')
  end

  def show
    @publication = Publication.find(params[:id])
  end

  def new
    @publication = Publication.new
    @locations = Location.find(:all, :order => "name")
  end

  def create
    @locations = Location.find(:all, :order => "name")
    if params[:cancel_button]
      redirect_to publications_path
    else
      @publication = Publication.new(params[:publication])
      if @publication.save
        flash[:notice] = "Publication Created"
        redirect_to publications_path
      else
        flash[:error] = "Publication Creation Failed"
        render :action => :new
      end
    end    
  end
  
  def edit
    @publication = Publication.find(params[:id])
    @locations = Location.find(:all, :order => "name")
  end

  def update
    @locations = Location.find(:all, :order => "name")
    @publication = Publication.find(params[:id])
    if @publication.update_attributes(params[:publication])
      flash[:notice] = "Publication updated"
      redirect_to publications_url
    else
      render :action => :edit
    end
  end
  
  def destroy
    @publication = Publication.find(params[:id])
    if @publication.destroy
      flash[:notice] = "Publication Killed!"
      redirect_to publications_path
    else
      flash[:error] = "Publication Deletion Failed"
      redirect_to publications_path
    end
  end
end
