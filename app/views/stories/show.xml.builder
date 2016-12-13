xml.DTIStory {

  if !@story.doc_name.nil?
    xml.StoryName "archive-"+@story.doc_name
  else
    xml.StoryName "archive-TheBulletin "+@story.pubdate.to_s
  end
  xml.Author @story.byline unless @story.byline.nil?
  xml.CategoryName @story.categoryname unless @story.categoryname.nil?
  xml.StoryCreatedTime @story.pubdate.strftime("%Y-%m-%d %H:%M:%S")
  xml.DeskName "zArchive"
  xml.Origin "Wescom Archive import"
  #xml.UserDefDate1 @story.pubdate.strftime("%Y-%m-%d %H:%M:%S")
  xml.UserDefStr1 "1"
  xml.PriorityName "- None"

  xml.StoryRunList {
    xml.StoryRunInfo {
      xml.RunDate @story.pubdate.strftime("%Y-%m-%d %H:%M:%S")
    }
  }

  xml.StoryElementsByName {
    xml.StoryElement("Name"=>"Kicker") { xml.text! @story.kicker unless @story.kicker.nil? } 
    xml.StoryElement("Name"=>"Headline") { xml.text! @story.hl1 unless @story.hl1.nil? }
    xml.StoryElement("Name"=>"WebHeadline") { xml.text! @story.web_hl1 unless @story.web_hl1.nil? }
    xml.StoryElement("Name"=>"SubHead") { xml.text! @story.hl2 unless @story.hl2.nil? }
    xml.StoryElement("Name"=>"WebSubHead") { xml.text! @story.web_hl2 unless @story.web_hl2.nil? }
    xml.StoryElement("Name"=>"Byline") { xml.text! @story.byline unless @story.byline.nil? }
    xml.StoryElement("Name"=>"Text") { xml.text! @story.copy unless @story.copy.nil? }
    xml.StoryElement("Name"=>"WebText") { xml.text! @story.web_text unless @story.web_text.nil? }
    xml.StoryElement("Name"=>"Toolbox") { xml.text! @story.sidebar_body unless @story.sidebar_body.nil? }
    xml.StoryElement("Name"=>"Toolbox2") { xml.text! @story.toolbox2 unless @story.toolbox2.nil? }
    xml.StoryElement("Name"=>"Toolbox3") { xml.text! @story.toolbox3 unless @story.toolbox3.nil? }
    xml.StoryElement("Name"=>"Toolbox4") { xml.text! @story.toolbox4 unless @story.toolbox4.nil? }
    xml.StoryElement("Name"=>"Toolbox5") { xml.text! @story.toolbox5 unless @story.toolbox5.nil? }
    xml.StoryElement("Name"=>"WebSummary") { xml.text! @story.web_summary unless @story.web_summary.nil? }
  }
}