class StoriesController < ApplicationController
  before_filter :require_user

  def show
    @story = Story.where(:id => params[:id]).includes(:corrections, :corrected_stories).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @story }
    end
  end
  
  def new
  end
  
  def create
  end
  
  def edit
    @story = Story.find(params[:id])
    @papers = Paper.find(:all, :order => "name")
    @sections = Section.order_by_category_plus_name.find(:all)
  end

  def update
    @story = Story.find(params[:id])
    @papers = Paper.find(:all, :order => "name")
    @sections = Section.order_by_category_plus_name.find(:all)

    if params[:cancel_button]
      redirect_to story_path
    else
      @story.attributes=(params[:story])
      if @story.save
        flash[:notice] = "Story Updated"
        redirect_to story_path
      else
        flash[:error] = "Story Update Failed"
        render :action => :edit
      end
    end
  end
  
  def destroy
    @story = Story.find(params[:id])
    if @story.destroy
      flash[:notice] = "Story Killed!"
      redirect_to :back and return unless request.referrer == story_path(@story)
      redirect_to search_path
    else
      flash[:error] = "Story Deletion Failed"
      redirect_to :back and return unless request.referrer == story_path(@story)
      redirect_to search_path
    end
  end
end
