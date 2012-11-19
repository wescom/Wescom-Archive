class StoriesController < ApplicationController
  before_filter :require_user
  def show
    @story = Story.where(:id => params[:id]).includes(:corrections, :corrected_stories).first
  end
  
  def destroy
    @story = Story.find(params[:id])
    if @story.destroy
      flash[:notice] = "Story Killed!"
      redirect_to :back and return unless request.referrer == story_path(@story)
      redirect_to search_path
    else
      flash[:error] = "Story Deletion Failed"
      redirect_to :back and return unless request.referrer == story_path(@story)
      redirect_to search_path
    end
  end
end
