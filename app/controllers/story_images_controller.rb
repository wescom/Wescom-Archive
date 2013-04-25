class StoryImagesController < ApplicationController
  before_filter :require_user
  
  def index
    @publications = Publication.find(:all)
    @sections = Section.order_by_category_plus_name.find(:all)
    @images = StoryImage
        .has_pubdate_in_range(params[:date_from_select], params[:date_to_select])
        .has_publication_id(params[:pub_select]).has_section_id(params[:section_select])
        .paginate(:page => params[:page], :per_page => 15)
        .order("image_updated_at DESC")
    @total_images_count = @images.count
  end
  
  def search
    @publications = Publication.find(:all)
    @sections = Section.order_by_category_plus_name.find(:all)
    if params[:search_query]
      begin
        @images = StoryImage.search(:include => [:story]) do
          paginate(:page => params[:page], :per_page => 15)
          fulltext params[:search_query]
          order_by :story_pubdate, :desc
          order_by :story_publication_name, :asc
          order_by :story_section_name, :asc
          order_by :story_page, :asc
          with(:story_pubdate).greater_than(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
          with(:story_pubdate).less_than(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
          with :story_publication_id, params[:pub_select] if params[:pub_select].present?
          with :story_section_id, params[:section_select] if params[:section_select].present?
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
