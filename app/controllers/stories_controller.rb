class StoriesController < ApplicationController
  def show
    @story = Story.where(:id => params[:id]).includes(:corrections, :corrected_stories).first
  end
end
