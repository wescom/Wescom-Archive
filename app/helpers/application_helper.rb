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
  
  def error_messages(object, field)   # ie: error_messages(@object, @object.field)
    if object.present?
      messages = object.errors["#{field}"].map { |msg| content_tag(:p, msg) }.join
      messages.gsub! "<p>", ""
      messages.gsub! "</p>", ""
      if messages.length > 0
        html = <<-HTML
        <span id="text-error">
          <img src = "/images/icons/exclamation.png" alt = "exclamation" /> #{messages}
        </span>
        HTML
        html.html_safe
      end
    end
  end
  
  def text_for_story_link(story)
    text = if !story.hl1.nil? and story.hl1.length > 0
      story.hl1
    elsif !story.web_hl1.nil? and story.web_hl1.length > 0
      story.web_hl1
    elsif !story.hl2.nil? and story.hl2.length > 0
      story.hl2
    elsif !story.web_hl2.nil? and story.web_hl2.length > 0
      story.web_hl2
    elsif !story.copy.nil? and story.copy.length > 0
      "No Headline. Story Copy: "+truncate(story.copy.gsub(/<.*?>/, ''), :length => 75)
    elsif !story.web_text.nil? and story.web_text.length > 0
      "No Headline. Story Copy: "+truncate(story.web_text.gsub(/<.*?>/, ''), :length => 75)
    else
      story.doc_name
    end
    # strip all nonalphanumberic characters 
#    text.html_safe.gsub(/\W/, ' ')
  end

  def text_for_image_link(image)
    text = if !image.media_name.nil? and image.media_name.length > 0
      image.media_name
    else
      image.media_id
    end
    # strip all nonalphanumberic characters 
#    text.html_safe.gsub(/\W/, '')
  end

  def strip_subhead_tags(text)
    text.html_safe.gsub(/<p class="hl2_chapterhead">/, '<p>')
  end
end
