xml.instruct! :xml, :version => "1.0" 

xml.story {

  xml.head {
    xml.pubdate @story.pubdate
    xml.publication @story.publication.name
    xml.section @story.section.name
    xml.page @story.page
    
    xml.hl1 @story.hl1
    xml.hl2 @story.hl2
    xml.byline @story.byline
  }

  xml.body {
    xml.copy @story.copy
    xml.tagline @story.tagline
  }
  
  xml.media {
    @story.story_images.each do |f|
      xml.image {
        xml.media_name f.media_name
        xml.media_filename f.media_source
      }
    end
  }
}