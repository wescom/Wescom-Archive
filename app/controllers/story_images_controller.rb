class StoryImagesController < ApplicationController
  before_filter :require_user
  
  def index
    @publications = Publication.find(:all)
    @sections = Section.find(:all, :order => "name")
    @images = StoryImage.paginate(:page => params[:page], 
                                  :order=> "image_updated_at DESC", 
                                  :per_page => 15)
    @total_images_count = StoryImage.count(:all)
  end
  
  def search
    @publications = Publication.find(:all)
    @sections = Section.find(:all, :order => "name")
    if params[:search_query]
      begin
        @images = StoryImage.search do
          paginate(:page => params[:page])
          fulltext params[:search_query]
          order_by :score, :desc
        end
      rescue Errno::ECONNREFUSED
        render :text => "Search Server Down\n\n\n It will be back online shortly"
      end
    end
    @total_images_count = StoryImage.count(:all)
  end

  def show
    @image = StoryImage.find(params[:id])
    render :layout => "plain"
  end
  
  def destroy
    @image = StoryImage.find(params[:id])
    @story = @image.story
    if @image.destroy
      flash[:notice] = "Image Deleted"
      redirect_to story_path(@story)
    else
      flash[:error] = "Image Deletion Failed"
      redirect_to :back and return unless request.referrer == story_path(@story)
      redirect_to search_path
    end
  end
end
