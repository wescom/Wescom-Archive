class StoriesController < ApplicationController
  before_filter :require_user
  def show
    @story = Story.where(:id => params[:id]).includes(:corrections, :corrected_stories).first
    if !@story.project_group.nil?
      @related_stories = Story.where(:project_group => @story.project_group)
    else
      @related_stories = nil
    end
  end
end
