# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def text_for_story_link(story)
    text = if !story.hl1.nil? and story.hl1.length > 0
      story.hl1
    elsif !story.hl2.nil?
      story.hl2
    elsif !story.copy.nil?
      truncate(story.copy.gsub(/<.*?>/, ''), :length => 50)
    else
      story.doc_name
    end
    text.html_safe
  end
end
