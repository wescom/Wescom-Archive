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
          facet(:publish_year)
          with(:publish_year, params[:year]) if params[:year].present?
        end
      rescue Errno::ECONNREFUSED
        render :text => "Search Server Down\n\n\n It will be back online shortly"
      end
    end
  end

  def today
    @stories = Story.where('DATE(pubdate) = ?', Date.today).paginate(:page => params[:page], :per_page => 30, :order => "Pubdate DESC")
  end
end
