class SectionCategoriesController < ApplicationController

  def index
    @section_categories = SectionCategory.all.order("name")
  end

  def show
    @section_categories = SectionCategory.find(params[:id])
  end

  def new
    @section_categories = SectionCategory.new
Rails.logger.info "********* NEW"
  end

  def create
    @section_categories = SectionCategory.new(params[:section_category])
Rails.logger.info "********* CREATE"
    if params[:cancel_button]
      redirect_to section_categories_path
    else
      if @section_categories.save
        flash_message :notice, "Section Category Created"
        redirect_to section_categories_path
      else
        flash_message :error, "Section Category Creation Failed"
        render :action => :new
      end
    end
  end
  
  def edit
    @section_categories = SectionCategory.find(params[:id])
  end

  def update
    @section_categories = SectionCategory.find(params[:id])
    if @section_categories.update_attributes(params[:section_category])
      flash_message :notice, "Section Category Updated"
      redirect_to section_categories_url
    else
      render :action => :edit
    end
  end
  
  def destroy
    @section_categories = SectionCategory.find(params[:id])
    if @section_categories.destroy
      flash_message :notice, "Section Category Killed!"
      redirect_to section_categories_path
    else
      flash_message :error, "Section Category Deletion Failed"
      redirect_to section_categories_path
    end
  end

end
