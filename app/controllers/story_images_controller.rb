class StoryImagesController < ApplicationController
  before_action :require_user
  
  def index
    @locations = Location.all.order('name')
    @pub_types = PublicationType.all.order('sort_order')

    @publications = Plan.where("pub_name is not null and pub_name<>''")
    @publications = @publications.where(:location_id => params[:location]) if params[:location].present?
    @publications = @publications.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @publications = @publications.select("DISTINCT pub_name").order('pub_name')

    @sections = Plan.where("section_name is not null and section_name<>''")
    @sections = @sections.where(:location_id => params[:location]) if params[:location].present?
    @sections = @sections.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @sections = @sections.where(:pub_name => params[:pub_select]) if params[:pub_select].present?
    @sections = @sections.select("DISTINCT section_name").order('section_name')

#    @images = StoryImage
#    @images = @images.has_pubdate_in_range(params[:date_from_select], params[:date_to_select])
#    @images = @images.joins(:story => :plan).where('location_id = ?',params[:location]) if params[:location].present? 
#    @images = @images.joins(:story => :plan).where('publication_type_id = ?',params[:pub_type]) if params[:pub_type].present? 
#    @images = @images.joins(:story => :plan).where('pub_name = ?',params[:pub_select]) if params[:pub_select].present? 
#    @images = @images.joins(:story => :plan).where('section_name = ?',params[:section_select]) if params[:section_select].present? 
#    @images = @images.paginate(:page => params[:page], :per_page => 15).order("id DESC")
    begin
      @images = StoryImage.search(:include => [:story]) do
        paginate(:page => params[:page], :per_page => 15)
        fulltext params[:search_query]
        order_by :story_pubdate, :desc
        order_by :story_publication_name, :asc
        order_by :story_section_name, :asc
        order_by :story_page, :asc
        with(:story_pubdate).greater_than_or_equal_to(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
        with(:story_pubdate).less_than_or_equal_to(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
        with :image_type, params[:image_type] if params[:image_type].present?
        with :story_location_id, params[:location] if params[:location].present?
        with :story_pub_type_id, params[:pub_type] if params[:pub_type].present?
        with :story_publication_name, params[:pub_select] if params[:pub_select].present?
        with :story_section_name, params[:section_select] if params[:section_select].present?
    end
    rescue Errno::ECONNREFUSED
      render :text => "Search Server Down\n\n\n It will be back online shortly"
    end
    
#    @total_images_count = @images.count
    @total_images_count = StoryImage.count(:all)
    increase_search_count
  end
  
  def search
    @locations = Location.all.order('name')
    @pub_types = PublicationType.all.order('sort_order')

    @publications = Plan.where("pub_name is not null and pub_name<>''")
    @publications = @publications.where(:location_id => params[:location]) if params[:location].present?
    @publications = @publications.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @publications = @publications.select("DISTINCT pub_name").order('pub_name')

    @sections = Plan.where("section_name is not null and section_name<>''")
    @sections = @sections.where(:location_id => params[:location]) if params[:location].present?
    @sections = @sections.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @sections = @sections.where(:pub_name => params[:pub_select]) if params[:pub_select].present?
    @sections = @sections.select("DISTINCT section_name").order('section_name')

    if params[:search_query]
      begin
        @images = StoryImage.search(:include => [:story]) do
          paginate(:page => params[:page], :per_page => 15)
          fulltext params[:search_query]
          order_by :story_pubdate, :desc
          order_by :story_publication_name, :asc
          order_by :story_section_name, :asc
          order_by :story_page, :asc
          with(:story_pubdate).greater_than_or_equal_to(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
          with(:story_pubdate).less_than_or_equal_to(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
          with :image_type, params[:image_type] if params[:image_type].present?
          with :story_location_id, params[:location] if params[:location].present?
          with :story_pub_type_id, params[:pub_type] if params[:pub_type].present?
          with :story_publication_name, params[:pub_select] if params[:pub_select].present?
          with :story_section_name, params[:section_select] if params[:section_select].present?
      end
      rescue Errno::ECONNREFUSED
        render :text => "Search Server Down\n\n\n It will be back online shortly"
      end
    end
    @total_images_count = StoryImage.count(:all)
    increase_search_count
  end

  def show
    @image = StoryImage.find(params[:id])
    @logs = @image.logs.all.order('created_at DESC')
    @last_updated = @logs.first
#    render :layout => "plain"
  end
  
  def edit
    @image = StoryImage.find(params[:id])
    @image_categories = StoryImage.distinct.pluck(:media_category)
    puts @image_categories.inspect
#    render :layout => "plain"
  end

  def update
    @image = StoryImage.find(params[:id])

    if params[:cancel_button]
      redirect_to story_image_path
    else
      @image.update_attributes(image_params)
      if @image.save
        Log.create_log("Story_image",@image.id,"Updated","Story Image edited",current_user)
        flash_message :notice, "Image Updated"
        redirect_to story_image_path
      else
        flash_message :error, "Image Update Failed"
        render :action => :edit
      end
    end
  end
  
  def destroy
    @image = StoryImage.find(params[:id])
    @story = @image.story
    if @image.destroy
      flash_message :notice, "Image Deleted"
      redirect_to story_path(@story)
    else
      flash_message :error, "Image Deletion Failed"
      redirect_to :back and return unless request.referrer == story_path(@story)
      redirect_to search_path
    end
  end

  private
  def image_params
    params.require(:story_image).permit(:media_printcaption, :media_printproducer, :media_webcaption, :media_originalcaption, 
      :media_byline, :media_source, :media_category, :forsale)
  end
end
