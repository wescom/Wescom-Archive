class SearchController < ApplicationController
  before_filter :require_user

  def index
    @settings = SiteSettings.find(:first)
    @publications = Publication.find(:all)
    @sections = Section.find(:all, :order => "name")
    if params[:search_query]
      begin
        @stories = Story.search do
          paginate(:page => params[:page])
          fulltext params[:search_query]
          order_by :pubdate, :desc
          order_by :story_publication_name, :asc
          order_by :story_section_name, :asc
          order_by :page, :asc
          with(:pubdate).greater_than(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
          with(:pubdate).less_than(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
          with :publication_id, params[:pub_select] if params[:pub_select].present?
          with :section_id, params[:section_select] if params[:section_select].present?
        end
      rescue Errno::ECONNREFUSED
        render :text => "Search Server Down\n\n\n It will be back online shortly"
      end
    end
    @total_stories_count = Story.count(:all)
  end

  def today
    @publications = Publication.find(:all)
    @publication = Publication.find(:first, :conditions => ['name = ?', params[:papername]])
    if params[:papername] == "All"
      @stories = Story.where('DATE(pubdate) = ?', Date.today).paginate(
                              :page => params[:page], 
                              :per_page => 30, 
                              :order => "Pubdate DESC").order_by_section_page
    else
      @stories = Story.where('DATE(pubdate) = ? and publication_id = ?', Date.today, @publication.id).paginate(
                              :page => params[:page], 
                              :per_page => 30, 
                              :order => "Pubdate DESC").order_by_section_page
    end
    @total_stories_count = @stories.count
  end
end