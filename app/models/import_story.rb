class ImportStory < ActiveRecord::Base
  attr_accessor :raw_xml, :doc_id, :copyright_holder, :doc_name
  attr_accessor :publication, :section, :pub_date, :page
  attr_accessor :body, :byline, :paper, :hl1, :hl2, :tagline
  attr_accessor :sidebar_head, :sidebar_body
  attr_accessor :media
  attr_accessor :correction, :original_story_id
  
  def initialize(xml)
    self.raw_xml = Nitf.parse(xml)
    self.correction = false

    self.raw_xml = cleanup_problems_in_keywords(self.raw_xml)
    self.raw_xml = cleanup_media_originalcaption(self.raw_xml)
    self.raw_xml = cleanup_hedline_tags(self.raw_xml)

    cracked = Crack::XML.parse(self.raw_xml)
    if cracked["nitf"]['head']['original_storyid']
      self.correction = true 
      self.original_story_id = cracked["nitf"]['head']['original_storyid'].to_i
      self.hl1 = "Correction"
    end
    
    doc_data = cracked["nitf"]["head"]["docdata"]
    pub_data = cracked["nitf"]["head"]["pubdata"]
    doc_body = cracked["nitf"]["body"]
    
    self.doc_id = doc_data["doc_id"]["id_string"].to_i
    self.copyright_holder = doc_data["doc.copyright"]["holder"]
    self.doc_name = doc_data["doc_name"]["name_string"]
    
    if !pub_data.nil?
      self.section = pub_data["position.section"].strip
      self.pub_date = pub_data["date.publication"].strip
      self.page = pub_data["position.sequence"].strip.to_i
      self.publication = pub_data["name"].strip
    end

    if !doc_body["body.content"].nil? 
      if !doc_body["body.content"]["p"].nil?    # Body Copy Content

        case doc_body["body.content"]["p"]
          when Array
            self.body = doc_body["body.content"]["p"].collect{|d| "<p>#{d.to_s.strip}</p>"}.join
          else
            self.body = "<p>" + doc_body["body.content"]["p"].to_s.strip + "</p>"
        end

        #if count_p_elements(doc_body["body.content"]) > 1
        #  self.body = doc_body["body.content"]["p"].collect{|d| "<p>#{d.to_s.strip}</p>"}.join
        #else
        #  self.body = "<p>" + doc_body["body.content"]["p"].to_s.strip + "</p>"
        #end
        #if self.body.length < 30
        #  self.body = doc_body["body.content"].collect{|d| "<p>#{d.to_s.strip}</p>"}.join
        #end

        self.body = fix_escaped_elements(self.body)
        self.body = handle_chapterheads_in_body(self.body)
      end

      if !doc_body["body.content"]["block"].nil?    # Sidebar Content
        # grab sidebar block from raw text to avoid bad parsing of xml
        start_of_sidebar_block = self.raw_xml.index('<block class="sidebar">')+23
        end_of_sidebar_block = self.raw_xml.index('</block>')-1
        self.sidebar_body = self.raw_xml[start_of_sidebar_block..end_of_sidebar_block]
        self.sidebar_body = fix_escaped_elements(self.sidebar_body)
        self.sidebar_body = handle_styling_in_sidebar(self.sidebar_body)
        #puts "sidebar_body: " + self.sidebar_body.to_s
      end

      if !doc_body["body.content"]["media"].nil?    # Media Content
        self.media = doc_body["body.content"]["media"]
        #puts "\nmedia info: \n"
        #puts self.media.to_s
      end
    end
    
    if !self.correction?
      self.byline = doc_body["body.head"]["byline"]["person"].to_s.rstrip.gsub(/^By\s/, '') if doc_body["body.head"]["byline"]
      if !doc_body["body.head"]["byline"].nil?
        self.paper = doc_body["body.head"]["byline"]["byttl"].to_s.strip if doc_body["body.head"]["byline"]["byttl"]
      end
      self.hl1 = doc_body["body.head"]["hedline"]["hl1"].to_s.chomp.strip.gsub(/\n/,'') if doc_body["body.head"]["hedline"]     
      if doc_body["body.head"]["hedline"] && doc_body["body.head"]["hedline"]["hl2"]
        self.hl2 = doc_body["body.head"]["hedline"]["hl2"].to_s.lstrip.rstrip
      end
      self.tagline = doc_body["body.end"]["tagline"].to_s.lstrip.rstrip if doc_body["body.end"]
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
  
  def fix_escaped_elements(string)
    return_string = string
#      return_string.gsub! /\342\200[\230\231]/, "'"
#      return_string.gsub! /\342\200[\234\235]/, '"'
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
    return_string
  end
  
  def handle_chapterheads_in_body(string)
    #puts string
    return_string = string
    return_string.gsub! '<p>{"em"=>{"p"=>"', '<p class="hl2_chapterhead">'
    return_string.gsub! '", "style"=>"bold", "class"=>"hl2_chapterhead"}}</p>', "</p>"
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
  
  def cleanup_hedline_tags(string)
    string = string
    start = string.index('<hedline>')
    stop = string.index('</hedline>')
    if !start.nil? && !stop.nil?
      start = start + 9
      hedline_string = string[start...stop]
      start_hl2 = string.index('<hl2>')
      if !start_hl2.nil?
        start_hl2 = start_hl2 + 5
        hl1_string = string[start...start_hl2]
        hl2_string = string[start_hl2...stop]
        hl2_string.gsub! "<hl2>", ""
        hl2_string.gsub! "</hl2>", ""
        string.gsub! string[start...stop], (hl1_string + hl2_string + "</hl2>")
      end
    end
    string
  end
end
