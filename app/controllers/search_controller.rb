class SearchController < ApplicationController
  before_filter :require_user

  def index
    @settings = SiteSettings.find(:first)
    @publications = Publication.find(:all)
    @sections = Section.order_by_category_plus_name.find(:all)
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
    @settings = SiteSettings.find(:first)

    scope = Plan.select(:pub_name).where("pub_name is not null and pub_name<>''")
    @publications = scope.uniq.order('pub_name')
    @publication = Plan.find(:first, :conditions => ['pub_name = ?', params[:papername]])

    if params[:paperdate].nil?
      Rails.logger.info "******** Date is nil"
      params[:paperdate] = Date.today.strftime('%m/%d/%Y')
    end
    if params[:papername] == "All" or params[:papername] == ""
      @stories = Story.where('DATE(pubdate) = ?', Date.strptime(params[:paperdate], "%m/%d/%Y"))
                            .paginate(
                              :page => params[:page], 
                              :per_page => 30, 
                              :order => "Pubdate DESC").order_by_pub_section_page
    else
      @stories = Story.where('DATE(pubdate) = ? and plans.pub_name = ?', Date.strptime(params[:paperdate], "%m/%d/%Y"), params[:papername])
                            .paginate(
                              :page => params[:page], 
                              :per_page => 30, 
                              :order => "Pubdate DESC").order_by_pub_section_page
    end
    @total_stories_count = @stories.count
  end
  
  def destroy
    @stories = Story.find(params[:id])
    if @stories.destroy
      flash[:notice] = "Story Killed!"
      redirect_to stories_path
    else
      flash[:error] = "Story Deletion Failed"
      redirect_to stories_path
    end
  end
end