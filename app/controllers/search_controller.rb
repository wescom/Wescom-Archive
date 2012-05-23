class SearchController < ApplicationController
  before_filter :require_user

  def index
    if params[:search_query]
      begin
        @stories = Story.search do
#          keywords(params[:search_query])
          paginate(:page => params[:page])
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
  end
end
