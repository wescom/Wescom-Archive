class StoryImagesController < ApplicationController
  before_filter :require_user
  
  def index
    @publications = Plan.where("pub_name is not null and pub_name<>''")
    @publications = @publications.where(:location_id => params[:location]) if params[:location].present?
    @publications = @publications.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @publications = @publications.select(:pub_name).uniq.order('pub_name')

    @sections = Plan.where("section_name is not null and section_name<>''")
    @sections = @sections.where(:location_id => params[:location]) if params[:location].present?
    @sections = @sections.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @sections = @sections.where(:pub_name => params[:pub_select]) if params[:pub_select].present?
    @sections = @sections.select(:section_name).uniq.order('section_name')

    scope = StoryImage
    scope = scope.has_pubdate_in_range(params[:date_from_select], params[:date_to_select])
    scope = scope.joins(:story => :plan).where('pub_name = ?',params[:pub_select]) if params[:pub_select].present? 
    scope = scope.joins(:story => :plan).where('section_name = ?',params[:section_select]) if params[:section_select].present? 
    @images = scope.paginate(:page => params[:page], :per_page => 16).order("id DESC")

    @total_images_count = @images.count
    increase_search_count
  end
  
  def search
    @locations = Location.find(:all, :order => 'name')
    @pub_types = PublicationType.find(:all, :order => 'sort_order')

    @publications = Plan.where("pub_name is not null and pub_name<>''")
    @publications = @publications.where(:location_id => params[:location]) if params[:location].present?
    @publications = @publications.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @publications = @publications.select(:pub_name).uniq.order('pub_name')

    @sections = Plan.where("section_name is not null and section_name<>''")
    @sections = @sections.where(:location_id => params[:location]) if params[:location].present?
    @sections = @sections.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @sections = @sections.where(:pub_name => params[:pub_select]) if params[:pub_select].present?
    @sections = @sections.select(:section_name).uniq.order('section_name')

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
    @logs = @image.logs.find(:all, :order => 'created_at DESC')
    @last_updated = @logs.first
    render :layout => "plain"
  end
  
  def edit
    @image = StoryImage.find(params[:id])
    render :layout => "plain"
  end

  def update
    @image = StoryImage.find(params[:id])

    if params[:cancel_button]
      redirect_to story_image_path
    else
      @image.attributes=(params[:story_image])
      if @image.save
        Log.create_log("Story_image",@image.id,"Updated","Story Image edited",current_user)
        flash[:notice] = "Image Updated"
        redirect_to story_image_path
      else
        flash[:error] = "Image Update Failed"
        render :action => :edit
      end
    end
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
