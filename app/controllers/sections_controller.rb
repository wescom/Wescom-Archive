class SectionsController < ApplicationController
  def index
    @sections = Section.paginate(:page => params[:page], :per_page => 60, :order=> "name")
  end

  def show
    @section = Section.find(params[:id])
  end

  def edit
    @section = Section.find(params[:id])
  end

  def update
    @section = Section.find(params[:id])
    if @section.update_attributes(params[:section])
      flash[:notice] = "Section updated"
      redirect_to sections_url
    else
      render :action => :edit
    end
  end

end
