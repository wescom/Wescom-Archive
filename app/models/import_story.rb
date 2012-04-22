class ImportStory < ActiveRecord::Base
  attr_accessor :raw_xml, :doc_id, :copyright_holder, :doc_name
  attr_accessor :publication, :section, :pub_date, :page
  attr_accessor :body, :byline, :paper, :hl1, :hl2, :tagline
  attr_accessor :sidebar_head, :sidebar_body
  attr_accessor :media
  attr_accessor :media_id, :media_name, :media_reference, :media_printcaption, :media_printproducer, :media_originalcaption
  attr_accessor :media_source, :media_byline, :media_job, :media_notes, :media_status, :media_type
  attr_accessor :correction, :original_story_id
  
  def initialize(xml)
    self.raw_xml = Nitf.parse(xml)
    self.correction = false
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
        if doc_body["body.content"]["p"].length < 30
          self.body = doc_body["body.content"]["p"].collect{|d| "<p>#{d.to_s.strip}</p>"}.join
        else
          self.body = "<p>" + doc_body["body.content"]["p"].to_s.strip + "</p>"
        end

        if self.body.length < 30
          self.body = doc_body["body.content"].collect{|d| "<p>#{d.to_s.strip}</p>"}.join
        end
        self.body = fix_escaped_elements(self.body)
        self.body = handle_chapterheads_in_body(self.body)
      end

      if !doc_body["body.content"]["block"].nil?    # Sidebar Content
        self.sidebar_head = doc_body["body.content"]["block"]["hl2"]
        self.sidebar_body = doc_body["body.content"]["block"]["p"].collect{|d| "<p>#{d.to_s.strip}</p>"}.join
        #puts "sidebar_head: " + self.sidebar_head.to_s
        #puts "sidebar_body: " + self.sidebar_body.to_s
      end

      if !doc_body["body.content"]["media"].nil?    # Media Content
        self.media = doc_body["body.content"]["media"]
        self.media_id = doc_body["body.content"]["media"]["media_id"]
        self.media_name = doc_body["body.content"]["media"]["media_name"]
        self.media_reference = doc_body["body.content"]["media"]["media_reference"]
        self.media_printcaption = doc_body["body.content"]["media"]["media_printcaption"]
        self.media_printproducer = doc_body["body.content"]["media"]["media_printproducer"]
        self.media_originalcaption = doc_body["body.content"]["media"]["media_originalcaption"]
        self.media_source = doc_body["body.content"]["media"]["media_source"]
        self.media_byline = doc_body["body.content"]["media"]["media_byline"]
        self.media_job = doc_body["body.content"]["media"]["media_job"]
        self.media_notes = doc_body["body.content"]["media"]["media_notes"]
        self.media_status = doc_body["body.content"]["media"]["media_status"]
        self.media_type = doc_body["body.content"]["media"]["media_type"]

        #puts "\nmedia info: \n"
        #puts self.media_id.to_s
        #puts self.media_name.to_s
        #puts self.media_reference.to_s
        #puts self.media_printcaption.to_s
        #puts self.media_printproducer.to_s
        #puts self.media_originalcaption.to_s
        #puts self.media_source.to_s
        #puts self.media_byline.to_s
        #puts self.media_job.to_s
        #puts self.media_notes.to_s
        #puts self.media_status.to_s
        #puts self.media_type.to_s
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
    # puts string
    return_string = string
    return_string.gsub! '<p>{"em"=>{"p"=>"', '<p class="hl2_chapterhead">'
    return_string.gsub! '", "style"=>"bold", "class"=>"hl2_chapterhead"}}</p>', "</p>"
    return_string    
  end
end