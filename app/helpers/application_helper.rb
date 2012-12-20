# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def admin?
    if User.find(session[:user_id]).role == "Admin"
      return true
    else
      return false
    end
  end
  
  def edit?
    if User.find(session[:user_id]).role == "Edit"
      return true
    else
      return false
    end
  end
  
  def text_for_story_link(story)
    text = if !story.hl1.nil? and story.hl1.length > 0
      story.hl1
    elsif !story.hl2.nil? and story.hl2.length > 0
      story.hl2
    elsif !story.copy.nil? and story.copy.length > 0
      truncate(story.copy.gsub(/<.*?>/, ''), :length => 50)
    else
      story.doc_name
    end
    # strip all nonalphanumberic characters 
    text.html_safe.gsub(/\W/, ' ')
  end

  def strip_subhead_tags(text)
    text.html_safe.gsub(/<p class="hl2_chapterhead">/, '<p>')
  end
end
