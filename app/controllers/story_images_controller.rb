class StoryImagesController < ApplicationController
  
  def show
    @image = StoryImage.find(params[:id])
  end
end
