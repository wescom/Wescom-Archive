class SearchController < ApplicationController
  before_action :require_user

  def index
    @settings = SiteSettings.first
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
        @stories = Story.search do
          paginate(:page => params[:page])
          fulltext params[:search_query]
          order_by :pubdate, :desc
          order_by :story_publication_name, :asc
          order_by :story_section_name, :asc
          order_by :page, :asc
          with(:pubdate).greater_than_or_equal_to(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
          with(:pubdate).less_than_or_equal_to(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
          with :story_location_id, params[:location] if params[:location].present?
          with :story_pub_type_id, params[:pub_type] if params[:pub_type].present?
          with :story_publication_name, params[:pub_select] if params[:pub_select].present?
          with :story_section_name, params[:section_select] if params[:section_select].present?
        end
      rescue Errno::ECONNREFUSED
        render :text => "Search Server Down\n\n\n It will be back online shortly"
      end
    end
    @total_stories_count = Story.count(:all)
    increase_search_count
  end

  def today
    @settings = SiteSettings.first

    @publications = Plan.select("DISTINCT pub_name").where("pub_name is not null and pub_name<>''").order('pub_name')
    @publication = Plan.where(:pub_name => params[:papername]).first if params[:papername].present?

    if params[:paperdate].nil? or params[:paperdate].empty?
      Rails.logger.info "******** Date is nil"
      params[:paperdate] = Date.today.strftime('%m/%d/%Y')
    end
    if params[:papername] == "All" or params[:papername] == ""
      @stories = Story.where('DATE(pubdate) = ?', Date.strptime(params[:paperdate], "%m/%d/%Y"))
                            .paginate(:page => params[:page],:per_page => 30)
                            .order_by_pub_section_page
    else
      @stories = Story.where('DATE(pubdate) = ? and plans.pub_name = ?', Date.strptime(params[:paperdate], "%m/%d/%Y"), params[:papername])
                            .paginate(:page => params[:page],:per_page => 30)
                            .order_by_pub_section_page
    end
    @total_stories_count = @stories.count
    increase_search_count
  end
  
  def destroy
    @stories = Story.find(params[:id])
    if @stories.destroy
      flash_message :notice, "Story Killed!"
      redirect_to stories_path
    else
      flash_message :error, "Story Deletion Failed"
      redirect_to stories_path
    end
  end
end