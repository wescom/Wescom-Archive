class StoriesController < ApplicationController
  before_filter :require_user
  def show
    @story = Story.where(:id => params[:id]).includes(:corrections, :corrected_stories).first
  end
end
