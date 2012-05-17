class StoryImagesController < ApplicationController
  
  def show
    @image = StoryImage.find(params[:id])
    render :layout => "plain"
  end
end
