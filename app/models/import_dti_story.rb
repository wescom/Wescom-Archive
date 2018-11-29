class ImportDtiStory
    include ActiveModel::Model
    
    attr_accessor :raw_xml, :storyid, :storyname, :author, :categoryname, :subcategoryname
    attr_accessor :created_at, :modified_at, :deskname, :expiredate, :keywords, :related_stories
    attr_accessor :project_group, :memo, :notes, :origin, :priority, :pub_corrections, :unpublished_corrections
    attr_accessor :status, :web_published_at, :web_pubnum, :printrunlist, :story_elements, :story_elements_by_name
    attr_accessor :rundate, :edition_name, :pageset_name, :pageset_letter, :page_number
    attr_accessor :hl1, :hl2, :byline, :paper, :print_text, :web_hl1, :web_hl2, :web_text, :web_summary
    attr_accessor :toolbox1, :toolbox2, :toolbox3, :toolbox4, :toolbox5
    attr_accessor :kicker, :tagline, :caption, :alternateurl, :map, :videourl, :htmltext
    attr_accessor :web_info, :latestSEO_url, :publish_to_web_datetime
    attr_accessor :media_list
    attr_accessor :correction, :original_story_id

  def initialize(xml)
    self.raw_xml = xml

#    self.raw_xml = cleanup_problems_in_keywords(self.raw_xml)
#    self.raw_xml = cleanup_media_originalcaption(self.raw_xml)
#    self.raw_xml = cleanup_hedline_tags(self.raw_xml)
#    self.raw_xml = cleanup_body_tags(self.raw_xml)

    self.raw_xml = Nitf.parse(xml)

    # Fix bad tags within raw_xml. These characters break the Crack parsing.
    self.raw_xml = fix_bad_tags(xml)
    
    cracked = Crack::XML.parse(self.raw_xml)
    self.storyid = cracked["DTIStory"]["StoryId"] unless cracked["DTIStory"]["StoryId"].nil?
    self.storyname = cracked["DTIStory"]["StoryName"] unless cracked["DTIStory"]["StoryName"].nil?
    self.project_group = cracked["DTIStory"]["Job"] unless cracked["DTIStory"]["Job"].nil?
    self.author = cracked["DTIStory"]["Author"] unless cracked["DTIStory"]["Author"].nil?
    self.origin = cracked["DTIStory"]["Origin"] unless cracked["DTIStory"]["Origin"].nil?

    self.deskname = cracked["DTIStory"]["DeskName"] unless cracked["DTIStory"]["DeskName"].nil?
    self.categoryname = cracked["DTIStory"]["CategoryName"] unless cracked["DTIStory"]["CategoryName"].nil?
    self.subcategoryname = cracked["DTIStory"]["SubCategoryName"] unless cracked["DTIStory"]["SubCategoryName"].nil?
    self.status = cracked["DTIStory"]["StatusName"] unless cracked["DTIStory"]["StatusName"].nil?
    self.priority = cracked["DTIStory"]["PriorityName"] unless cracked["DTIStory"]["PriorityName"].nil?
    self.memo = cracked["DTIStory"]["Memo"] unless cracked["DTIStory"]["Memo"].nil?
    self.notes = cracked["DTIStory"]["Notes"] unless cracked["DTIStory"]["Notes"].nil?

    self.related_stories = cracked["DTIStory"]["UserDefStr5"] unless cracked["DTIStory"]["UserDefStr5"].nil?

    self.created_at = cracked["DTIStory"]["StoryCreatedTime"] unless cracked["DTIStory"]["StoryCreatedTime"].nil?
    self.modified_at = cracked["DTIStory"]["LastModifiedTime"] unless cracked["DTIStory"]["LastModifiedTime"].nil?
    self.expiredate = cracked["DTIStory"]["ExpireDate"] unless cracked["DTIStory"]["ExpireDate"].nil?
    self.web_published_at = cracked["DTIStory"]["UserDefDate1"] unless cracked["DTIStory"]["UserDefDate1"].nil?
    self.web_pubnum = cracked["DTIStory"]["UserDefStr1"] unless cracked["DTIStory"]["UserDefStr1"].nil?

    self.pub_corrections = cracked["DTIStory"]["PubCorrections"] unless cracked["DTIStory"]["PubCorrections"].nil?
    self.unpublished_corrections = cracked["DTIStory"]["UnpublishedCorrections"] unless cracked["DTIStory"]["UnpublishedCorrections"].nil?

    keyword_data = cracked["DTIStory"]["KeywordList"]["Keyword"] unless cracked["DTIStory"]["KeywordList"].nil?
    self.keywords = keyword_data
    
    printrunlist_data = cracked["DTIStory"]["PrintRunList"]["PrintRunInfo"] unless cracked["DTIStory"]["PrintRunList"].nil?
    if !printrunlist_data.nil?
      if printrunlist_data.kind_of?(Array)
        data = printrunlist_data.shift  # Grab first item in array
      else
        data = printrunlist_data
      end
      self.rundate = data["RunDate"] unless data["RunDate"].nil?
      self.edition_name = data["EditionName"] unless data["EditionName"].nil?
      self.pageset_name = data["PageSetName"] unless data["PageSetName"].nil?
      self.pageset_letter = data["PageSetLetter"] unless data["PageSetLetter"].nil?
      self.page_number = data["PageNumber"] unless data["PageNumber"].nil?
    else
      # Story did not print but was web only
      case web_pubnum
        when "1"
           self.edition_name ="The Bulletin"
        when "2"
          self.edition_name ="Baker City Herald"
        when "3"
          self.edition_name ="The Observer"
        when "4"
          self.edition_name ="Redmond Spokesman"
        when "7"
          self.edition_name ="The Triplicate"
        when "8"
          self.edition_name ="Curry Coastal Pilot"
        when "9"
          self.edition_name ="Union Democrat"
        else
          self.edition_name ="Web Only"
      end
      self.pageset_name = "Web Only"
    end

    self.story_elements = cracked["DTIStory"]["StoryElementList"]["StoryElement"] unless cracked["DTIStory"]["StoryElementList"].nil?
    if !self.story_elements.nil?
        story_elements = []
      if self.story_elements.kind_of?(Array)   # Multiple Story elements
        count = 0
        self.story_elements.each { |x|
          story_elements[count] = x.slice("storyElementName","elementStyleMarkUp")
          count += 1
        }
      else    # Only one Story element
        story_elements[0] = self.story_elements.slice("storyElementName","elementStyleMarkUp")
      end
      self.story_elements = story_elements

      self.hl1 = self.story_elements.select.reject{|x| x["storyElementName"] != "hl1"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.hl1 = fix_escaped_elements(self.hl1) unless self.hl1.nil?
      self.hl1 = strip_formatting(self.hl1) unless self.hl1.nil?
      self.hl1 = self.hl1.gsub(/<[^<>]*>/, "") unless self.hl1.nil? #Remove all tags from string

      self.web_hl1 = self.story_elements.select.reject{|x| x["storyElementName"] != "web.headline"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.web_hl1 = fix_escaped_elements(self.web_hl1) unless self.web_hl1.nil?
      self.web_hl1 = strip_formatting(self.web_hl1) unless self.web_hl1.nil?
      self.web_hl1 = self.web_hl1.gsub(/<[^<>]*>/, "") unless self.web_hl1.nil? #Remove all tags from string

      self.hl2 = self.story_elements.select.reject{|x| x["storyElementName"] != "hl2"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.hl2 = fix_escaped_elements(self.hl2) unless self.hl2.nil?
      self.hl2 = strip_formatting(self.hl2) unless self.hl2.nil?

      self.web_hl2 = self.story_elements.select.reject{|x| x["storyElementName"] != "web.subhead"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.web_hl2 = fix_escaped_elements(self.web_hl2) unless self.web_hl2.nil?
      self.web_hl2 = strip_formatting(self.web_hl2) unless self.web_hl2.nil?

      self.byline = self.story_elements.select.reject{|x| x["storyElementName"] != "bytag"}.collect{|x| x["elementStyleMarkUp"] }.join.split("</p>")
      if !self.byline.empty?
        self.paper = self.byline[1].nil? ? "" : self.byline[1]
        self.paper = self.paper.gsub(/<[^<>]*>/, "") unless self.paper.nil? #Remove all tags from string
        self.byline = self.byline[0] unless self.byline[0].nil?
        self.byline = fix_escaped_elements(self.byline) unless self.byline.nil?
        self.byline = self.byline.gsub(/<[^<>]*>/, "") unless self.byline.nil? #Remove all tags from string
        self.byline = self.byline.gsub(/^By /, "") unless self.byline.nil?
      else
        self.byline = ""
        self.paper = ""
      end

      self.print_text = self.story_elements.select.reject{|x| x["storyElementName"] != "text"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.print_text = fix_escaped_elements(self.print_text) unless self.print_text.nil?
      self.print_text = handle_chapterheads_in_body(self.print_text) unless self.print_text.nil?
      self.print_text = self.print_text.encode('utf-8') unless self.print_text.nil?

      self.web_text = self.story_elements.select.reject{|x| x["storyElementName"] != "web.text"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.web_text = fix_escaped_elements(self.web_text) unless self.web_text.nil?
      self.web_text = handle_chapterheads_in_body(self.web_text) unless self.web_text.nil?
      self.web_text = self.web_text.encode('utf-8') unless self.web_text.nil?

      self.toolbox1 = self.story_elements.select.reject{|x| x["storyElementName"] != "mug.line"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.toolbox1 = fix_escaped_elements(self.toolbox1) unless self.toolbox1.nil?
      self.toolbox1 = handle_chapterheads_in_body(self.toolbox1) unless self.toolbox1.nil?
      self.toolbox1 = self.toolbox1.encode('utf-8') unless self.toolbox1.nil?

      self.toolbox2 = self.story_elements.select.reject{|x| x["storyElementName"] != "toolbox2"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.toolbox2 = fix_escaped_elements(self.toolbox2) unless self.toolbox2.nil?
      self.toolbox2 = handle_chapterheads_in_body(self.toolbox2) unless self.toolbox2.nil?
      self.toolbox2 = self.toolbox2.encode('utf-8') unless self.toolbox2.nil?

      self.toolbox3 = self.story_elements.select.reject{|x| x["storyElementName"] != "toolbox3"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.toolbox3 = fix_escaped_elements(self.toolbox3) unless self.toolbox3.nil?
      self.toolbox3 = handle_chapterheads_in_body(self.toolbox3) unless self.toolbox3.nil?
      self.toolbox3 = self.toolbox3.encode('utf-8') unless self.toolbox3.nil?

      self.toolbox4 = self.story_elements.select.reject{|x| x["storyElementName"] != "toolbox4"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.toolbox4 = fix_escaped_elements(self.toolbox4) unless self.toolbox4.nil?
      self.toolbox4 = handle_chapterheads_in_body(self.toolbox4) unless self.toolbox4.nil?
      self.toolbox4 = self.toolbox4.encode('utf-8') unless self.toolbox4.nil?

      self.toolbox5 = self.story_elements.select.reject{|x| x["storyElementName"] != "toolbox5"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.toolbox5 = fix_escaped_elements(self.toolbox5) unless self.toolbox5.nil?
      self.toolbox5 = handle_chapterheads_in_body(self.toolbox5) unless self.toolbox5.nil?
      self.toolbox5 = self.toolbox5.encode('utf-8') unless self.toolbox5.nil?

      self.kicker = self.story_elements.select.reject{|x| x["storyElementName"] != "kicker"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.kicker = fix_escaped_elements(self.kicker) unless self.kicker.nil?
      self.kicker = handle_chapterheads_in_body(self.kicker) unless self.kicker.nil?

      self.htmltext = self.story_elements.select.reject{|x| x["storyElementName"] != "htmltext"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.htmltext = fix_escaped_elements(self.htmltext) unless self.htmltext.nil?
      self.htmltext = handle_chapterheads_in_body(self.htmltext) unless self.htmltext.nil?

      self.web_summary = self.story_elements.select.reject{|x| x["storyElementName"] != "quick.read"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.web_summary = fix_escaped_elements(self.web_summary) unless self.web_summary.nil?
      self.web_summary = handle_chapterheads_in_body(self.web_summary) unless self.web_summary.nil?

      self.videourl = self.story_elements.select.reject{|x| x["storyElementName"] != "video"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.videourl = fix_escaped_elements(self.videourl) unless self.videourl.nil?
      self.videourl = handle_chapterheads_in_body(self.videourl) unless self.videourl.nil?

      self.alternateurl = self.story_elements.select.reject{|x| x["storyElementName"] != "alternateurl"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.alternateurl = fix_escaped_elements(self.alternateurl) unless self.alternateurl.nil?
      self.alternateurl = handle_chapterheads_in_body(self.alternateurl) unless self.alternateurl.nil?

      self.map = self.story_elements.select.reject{|x| x["storyElementName"] != "map.location"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.map = fix_escaped_elements(self.map) unless self.map.nil?
      self.map = handle_chapterheads_in_body(self.map) unless self.map.nil?

      self.caption = self.story_elements.select.reject{|x| x["storyElementName"] != "caption"}.collect{|x| x["elementStyleMarkUp"] }.join
      self.caption = fix_escaped_elements(self.caption) unless self.caption.nil?
    end

    self.story_elements_by_name = cracked["DTIStory"]["StoryElementsByName"] unless cracked["DTIStory"]["StoryElementsByName"].nil?

    self.web_info = cracked["DTIStory"]["WebInfo"]["LightningWebInfo"] unless cracked["DTIStory"]["WebInfo"]["LightningWebInfo"].nil?
    self.latestSEO_url = self.web_info["LatestSEOURL"] unless web_info["LatestSEOURL"].nil?
    self.publish_to_web_datetime = self.web_info["PublishToWebDateTime"] unless web_info["PublishToWebDateTime"].nil?
    if self.rundate.nil?
      self.rundate = self.web_info["PublishToWebDateTime"] unless web_info["PublishToWebDateTime"].nil?
    end
    
    media_data = cracked["DTIStory"]["MediaList"]["MediaItem"] unless cracked["DTIStory"]["MediaList"].nil?
    if !media_data.nil?
      self.media_list = []
      if media_data.length == 51  # 51 fields means it is a single media record
        self.media_list[0] = media_data.slice("FileHeaderId","FileHeaderName",
          "FileTypeExtension","NativeFileExtension","Byline","BylineTitle","Source","OriginalIPTCCaption","PrintCaption",
          "CreatorsName","Depth","Width","DeskName","StatusName","PriorityName","Job","Notes","UserDefinedText1",
          "CreatedDate","LastModifiedTime","LastRefreshedTime","ExpireDate","RelatedStoriesList","RunList","CategoryName")
      else    # more than one media record
        count = 0
        media_data.each { |x|
          self.media_list[count] = x.slice("FileHeaderId","FileHeaderName",
            "FileTypeExtension","NativeFileExtension","Byline","BylineTitle","Source","OriginalIPTCCaption","PrintCaption",
            "CreatorsName","Depth","Width","DeskName","StatusName","PriorityName","Job","Notes","UserDefinedText1",
            "CreatedDate","LastModifiedTime","LastRefreshedTime","ExpireDate","RelatedStoriesList","RunList","CategoryName")
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

  def fix_bad_tags(string)
    if !string.nil?
      return_string = string
      return_string.gsub! '<2044>', "/"
      return_string
    else
      string
    end
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
      #return_string.gsub! '<p>', ''
      #return_string.gsub! '</p>', ''
      return_string    
    end
  end

  def fix_escaped_elements(string)
    if !string.nil?
      return_string = string
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

  def handle_styling_in_toolbox(string)
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
