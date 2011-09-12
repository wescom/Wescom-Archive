class SearchController < ApplicationController
  def index
    if params[:search_query]
      @stories = Story.search do
        keywords(params[:search_query])
        paginate(:page => params[:page])
      end
    end
  end

  def today
  end
end
