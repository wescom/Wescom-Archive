class SectionsController < ApplicationController
  def index
    @sections = Section.paginate(:page => params[:page], :per_page => 60).order_by_category_plus_name
  end

  def show
    @section = Section.find(params[:id])
  end

  def edit
    @section = Section.find(params[:id])
    @section_categories = SectionCategory.all.order("name")
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
  
  def destroy
    @section = Section.find(params[:id])
    if @section.destroy
      flash[:notice] = "Story Killed!"
      redirect_to sections_path
    else
      flash[:error] = "Story Deletion Failed"
      redirect_to sections_path
    end
  end

end
