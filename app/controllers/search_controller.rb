class SearchController < ApplicationController
  before_filter :require_user

  def index
    if params[:search_query]
      begin
        @stories = Story.search do
#          keywords(params[:search_query])
          paginate(:page => params[:page])
          order_by :pubdate, :desc
          fulltext params[:search_query]
#          facet(:publish_year)
#          with(:publish_year, params[:year]) if params[:year].present?
        end
      rescue Errno::ECONNREFUSED
        render :text => "Search Server Down\n\n\n It will be back online shortly"
      end
    end
    @total_stories_count = Story.count(:all)
    @publications = Publication.find(:all)
  end

  def today
    @publications = Publication.find(:all)
    Rails.logger.info "**** " + @publications.to_s
    Rails.logger.info "**** " + params[:papername]
    @papername = params[:papername]
Rails.logger.info "**** " + @paper.to_s
    @stories = Story.where('DATE(pubdate) = ? and publication_id = ?', Date.today, @paper).paginate(
                            :page => params[:page], 
                            :per_page => 30, 
                            :order => "Pubdate DESC").order_by_section_page
    @total_stories_count = @stories.count
  end
end
