class ImportDtiStory < ActiveRecord::Base
  attr_accessor :raw_xml, :storyid, :storyname, :author, :categoryname, :subcategoryname
  attr_accessor :created_at, :modified_at, :deskname, :expiredate, :keywords
  attr_accessor :project_group, :memo, :notes, :origin, :priority, :pub_corrections, :unpublished_corrections
  attr_accessor :status, :web_published_at, :printrunlist, :story_elements, :story_elements_by_name, :tagline
  attr_accessor :rundate, :edition_name, :pageset_name, :pageset_letter, :page_number
  attr_accessor :hl1, :hl2, :byline, :print_text, :web_hl1, :web_hl2, :web_text
  attr_accessor :sidebar_head, :sidebar_body, :tagline
  attr_accessor :web_info, :latestSEO_url, :publish_to_web_datetime
  attr_accessor :media_list
  attr_accessor :correction, :original_story_id

  def initialize(xml)
    self.raw_xml = xml

#    self.raw_xml = cleanup_problems_in_keywords(self.raw_xml)
#    self.raw_xml = cleanup_media_originalcaption(self.raw_xml)
#    self.raw_xml = cleanup_hedline_tags(self.raw_xml)
#    self.raw_xml = cleanup_body_tags(self.raw_xml)

    cracked = Crack::XML.parse(self.raw_xml)
    self.storyid = cracked["DTIStory"]["StoryId"]
    self.storyname = cracked["DTIStory"]["StoryName"]
    self.project_group = cracked["DTIStory"]["Job"]
    self.author = cracked["DTIStory"]["Author"]
    self.origin = cracked["DTIStory"]["Origin"]

    self.deskname = cracked["DTIStory"]["DeskName"]
    self.categoryname = cracked["DTIStory"]["CategoryName"]
    self.subcategoryname = cracked["DTIStory"]["SubCategoryName"]
    self.status = cracked["DTIStory"]["StatusName"]
    self.priority = cracked["DTIStory"]["PriorityName"]
    self.memo = cracked["DTIStory"]["Memo"]
    self.notes = cracked["DTIStory"]["Notes"]

    self.created_at = cracked["DTIStory"]["StoryCreatedTime"]
    self.modified_at = cracked["DTIStory"]["LastModifiedTime"]
    self.expiredate = cracked["DTIStory"]["ExpireDate"]
    self.web_published_at = cracked["DTIStory"]["UserDefDate1"]

    self.pub_corrections = cracked["DTIStory"]["PubCorrections"]
    self.unpublished_corrections = cracked["DTIStory"]["UnpublishedCorrections"]

    keyword_data = cracked["DTIStory"]["KeywordList"]["Keyword"]
    self.keywords = keyword_data
    
    printrunlist_data = cracked["DTIStory"]["PrintRunList"]["PrintRunInfo"]
    if !printrunlist_data.nil?
      if printrunlist_data.count == 1
        data = printrunlist_data
      else
        data = printrunlist_data.shift  # Grab first item in hash
      end
      self.rundate = data["RunDate"]
      self.edition_name = data["EditionName"]
      self.pageset_name = data["PageSetName"]
      self.pageset_letter = data["PageSetLetter"]
      self.page_number = data["PageNumber"]
    end
    
    self.story_elements = cracked["DTIStory"]["StoryElementList"]
    # still need to grab toolbox element, called mug.line
    # print.caption would be nice as well

    self.story_elements_by_name = cracked["DTIStory"]["StoryElementsByName"]
    self.hl1 = self.story_elements_by_name["HeadlineDelimitedList"]
    self.hl2 = self.story_elements_by_name["SubHeadlineDelimitedList"]
    self.byline = self.story_elements_by_name["BylineDelimitedList"]
    self.print_text = self.story_elements_by_name["TextDelimitedList"]
    self.web_hl1 = self.story_elements_by_name["WebHeadlineDelimitedList"]
    self.web_hl2 = self.story_elements_by_name["WebSubHeadlineDelimitedList"]
    self.web_text = self.story_elements_by_name["WebTextDelimitedList"]
    self.sidebar_body = ""
    self.sidebar_head = ""
    self.tagline = ""

    self.web_info = cracked["DTIStory"]["WebInfo"]["LightningWebInfo"]
    self.latestSEO_url = self.web_info["LatestSEOURL"]
    self.publish_to_web_datetime = self.web_info["PublishToWebDateTime"]
    
    media_data = cracked["DTIStory"]["MediaList"]["MediaItem"]
    if !media_data.nil?
      self.media_list = []
      if media_data.length == 51  # 51 fields means it is a single media record
        self.media_list[0] = media_data.slice("FileHeaderId","FileHeaderName",
          "FileTypeExtension","NativeFileExtension","Byline","BylineTitle","Source","OriginalIPTCCaption","PrintCaption",
          "CreatorsName","Depth","Width","DeskName","StatusName","PriorityName","Job","Notes","UserDefinedText1",
          "CreatedDate","LastModifiedTime","LastRefreshedTime","ExpireDate","RelatedStoriesList")
      else    # more than one media record
        count = 0
        media_data.each { |x|
          self.media_list[count] = x.slice("FileHeaderId","FileHeaderName",
            "FileTypeExtension","NativeFileExtension","Byline","BylineTitle","Source","OriginalIPTCCaption","PrintCaption",
            "CreatorsName","Depth","Width","DeskName","StatusName","PriorityName","Job","Notes","UserDefinedText1",
            "CreatedDate","LastModifiedTime","LastRefreshedTime","ExpireDate","RelatedStoriesList")
          count += 1
        }
      end
    end
  end    

  def correction?
    self.correction
  end

  def count_p_elements(hash)
    count = 0
    hash.each_key { |key|
      count = count + 1 unless key != "p"
    }
    return count
  end

  def strip_formatting(string)
    if !string.nil?
      return_string = string
      return_string.gsub! '<p>{"em"=>{"p"=>"', ''
      return_string.gsub! '", "style"=>"bold", "class"=>"hl2_chapterhead"}}</p>', ''
      return_string.gsub! '<p>{"em"=>"', ''
      return_string.gsub! '<p>{"hl2"=>"', ''
      return_string.gsub! '<p>{"p"=>"', ''
      return_string.gsub! '<p>{"hl2_chapterhead"=>"', ''
      return_string.gsub! '{"hl2_chapterhead"=>"', ''
      return_string.gsub! '"}</p>', ''
      return_string.gsub! '{"p"=>nil}', ''
      return_string.gsub! '<p>["p", " ', ''
      return_string.gsub! ' "]</p>', ''
      return_string    
    end
  end

  def fix_escaped_elements(string)
    if !string.nil?
      return_string = string
  #      return_string.gsub! /\342\200[\230\231]/, "'"
  #      return_string.gsub! /\342\200[\234\235]/, '"'
      return_string.gsub! '&#x2002', " "
      return_string.gsub! '&#x2008', "-"
      return_string.gsub! '&#x2009', "-"
      return_string.gsub! '&#x2010', "-"
      return_string.gsub! '&#x2011', "-"
      return_string.gsub! '&#x2012', "--"
      return_string.gsub! '&#x2013', "--"
      return_string.gsub! '&#x2014', "--"
      return_string.gsub! '&#x2015', "--"
      return_string.gsub! '&#x2016', "'"
      return_string.gsub! '&#x2017', "'"
      return_string.gsub! '&#x2018', "'"
      return_string.gsub! '&#x2019', "'"
      return_string.gsub! '&#x2020', '"'
      return_string.gsub! '&#x2021', '"'
      return_string.gsub! '&#x2022', '*'
      return_string.gsub! '&#x2030', "..."
      return_string.gsub! '&#x2044', "/"
      return_string.gsub! '&#x201c', '"'
      return_string.gsub! '&#x201d', '"'
      return_string
    else
      string
    end
  end

  def handle_chapterheads_in_body(string)
    #puts string
    return_string = string
    return_string.gsub! '<p>{"em"=>{"p"=>"', '<p class="hl2_chapterhead">'
    return_string.gsub! '", "style"=>"bold", "class"=>"hl2_chapterhead"}}</p>', "</p>"
    return_string.gsub! '<p>{"em"=>"', '<p class="hl2_chapterhead">'
    return_string.gsub! '<p>{"hl2"=>"', '<p class="hl2_chapterhead">'
    return_string.gsub! '<p>{"p"=>"', '<p class="hl2_chapterhead">'
    return_string.gsub! '<p>{"hl2_chapterhead"=>"', '<p class="hl2_chapterhead">'
    return_string.gsub! '"}</p>', "</p>"
    return_string.gsub! '{"p"=>nil}', ""
    return_string.gsub! '<p>["p", " ', '<p class="hl2_chapterhead">'
    return_string.gsub! ' "]</p>', '</p>'
    return_string    
  end

  def handle_styling_in_sidebar(string)
    #puts string
    return_string = string
    return_string.gsub! '<hl2>', '<p class="hl2_head">'
    return_string.gsub! '</hl2>', "</p>"
    return_string.gsub! '<p><em style="bold" class="hl2_chapterhead"><p>', '<p class="hl2_chapterhead">'
    return_string.gsub! '</p></em></p>', "</p>"
    return_string    
  end

  def cleanup_problems_in_keywords(string)    # remove all bad ' characters
    string = string
    start = string.index('<tobject tobject.type="news">')
    stop = string.index('</tobject>')
    if !start.nil? && !stop.nil?
      start = start + 29
      keywords_string = string[start...stop]

      keywords_string.gsub! "<Keyword name = '", '"'
      keywords_string.gsub! "'/>", '"'
      keywords_string.gsub! '""', '","'
      keywords_string.gsub! "\n", ""
      keywords_string = "[" + keywords_string.strip + "]"
      keywords_string = eval(keywords_string)

      new_string = ""
      keywords_string.each {|x|
        x.gsub! "'", ""
        new_string = new_string + "<Keyword name = '" + x + "'/>"
      }

      return_string = string.gsub! string[start...stop], new_string
      #puts return_string
      return_string
    else
      string
    end
  end

  def cleanup_media_originalcaption(string)     # remove all <p> tags
    string = string
    start = string.index('<media-originalcaption>')
    stop = string.index('</media-originalcaption>')
    string_end = string.length
    while !start.nil? && !stop.nil?
      start = start + 23
      caption_string = string[start...stop]
      caption_string.gsub! "<p>", ""
      caption_string.gsub! "</p>", ""
      string.gsub! string[start...stop], caption_string

      if string[stop...string_end].index('<media-originalcaption>')   # Any more occurances?
        start = string[stop...string_end].index('<media-originalcaption>') + stop
        stop = string[(stop+24)...string_end].index('</media-originalcaption>') + stop+24
      else
        return string
      end
    end
    string
  end

  def cleanup_hedline_tags(string)    # remove extra hl2 tags within <hedline>
    string = string
    start = string.index('<hedline>')
    stop = string.index('</hedline>')
    if !start.nil? && !stop.nil?
      start = start + 9
      hedline_string = string[start...stop]
      start_hl2 = hedline_string.index('<hl2>')
      if !start_hl2.nil?
        start_hl2 = start_hl2 + 5
        hl1_string = hedline_string[1...start_hl2]
        hl2_string = hedline_string[start_hl2...stop]
        hl2_string.gsub! "<hl2>", ""
        hl2_string.gsub! "</hl2>", ""
        string.gsub! string[start...stop], (hl1_string + hl2_string + "</hl2>")
      end
    end
    string
  end

  def cleanup_body_tags(string)    # replace hl2 tags within <p>{"hl2_chapterhead"=>"
    string.gsub! '<hl2>', '<p>{"hl2_chapterhead"=>"'
    string.gsub! '</hl2>', '</p>'
    string
  end
end
