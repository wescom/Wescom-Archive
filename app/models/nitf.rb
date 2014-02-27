class Nitf < ActiveRecord::Base
  dir = File.dirname(__FILE__)
  @@utf_table = YAML::load_file(File.join(dir, 'lookup_table.yml'))

  def self.parse(file_string)
    @@story_string = cleanup_text(file_string)
    @@story_string
  end

  private
  def self.cleanup_text(file_string)
    file_string.gsub!("\xEF\xBB\xBF".force_encoding("ASCII-8BIT"), ' ')    #BOMS
    file_string.gsub!("\xE2\x80\xA8".force_encoding("ASCII-8BIT"), ' ')    #BOMS
    file_string.gsub!("\xE2\x80\x89".force_encoding("ASCII-8BIT"), ' ')   #BOMS
    file_string.gsub!("\xE2\x80\x82".force_encoding("ASCII-8BIT"), ' ')    #EM Space
    file_string.gsub!("\xE2\x80\x83".force_encoding("ASCII-8BIT"), ' ')    #EM Space
    file_string.gsub!("\xE2\x81\x84".force_encoding("ASCII-8BIT"), '/')    #BOMS
    file_string.gsub! /\t/, ' '
    file_string.gsub! /([\x00-\x09])/, ''
    file_string.gsub! /([\x0B\x0C\x0E-\x1F])/, ''
    file_string.gsub!("\xC2\x82".force_encoding("ASCII-8BIT"), ',')   # High code comma
    file_string.gsub!("\xC2\x84".force_encoding("ASCII-8BIT"), ',,')  # High code double comma
    file_string.gsub!("\xC2\x85".force_encoding("ASCII-8BIT"), '...') # Tripple dot
    file_string.gsub!("\xC2\x88".force_encoding("ASCII-8BIT"), '^')   # High carat
    file_string.gsub!("\xC2\x91".force_encoding("ASCII-8BIT"), "'")   # Forward single quote
    file_string.gsub!("\xC2\x92".force_encoding("ASCII-8BIT"), "'")   # Reverse single quote
    file_string.gsub!("\xC2\x93".force_encoding("ASCII-8BIT"), '"')   # Forward double quote
    file_string.gsub!("\xC2\x94".force_encoding("ASCII-8BIT"), '"')   # Reverse double quote
    file_string.gsub!("\xC2\x95".force_encoding("ASCII-8BIT"), ' ')
    file_string.gsub!("\xC2\x96".force_encoding("ASCII-8BIT"), '-')   # High hyphen
    file_string.gsub!("\xC2\x97".force_encoding("ASCII-8BIT"), '--')  # Double hyphen
    file_string.gsub!("\xC2\x99".force_encoding("ASCII-8BIT"), ' ')
    file_string.gsub!("\xC2\xa0".force_encoding("ASCII-8BIT"), ' ')
    file_string.gsub!("\xC2\xa6".force_encoding("ASCII-8BIT"), '|')   # Split vertical bar
    file_string.gsub!("\xC2\xab".force_encoding("ASCII-8BIT"), '<<')  # Double less than
    file_string.gsub!("\xC2\xbb".force_encoding("ASCII-8BIT"), '>>')  # Double greater than
    file_string.gsub!("\xE2\x80\xA9".force_encoding("ASCII-8BIT"), '')    #
    file_string.gsub!("\xE2\x85\x90".force_encoding("ASCII-8BIT"), '1/7')    #one seventh
    file_string.gsub!("\xE2\x85\x91".force_encoding("ASCII-8BIT"), '1/9')    #one ninth
    file_string.gsub!("\xE2\x85\x92".force_encoding("ASCII-8BIT"), '1/10')    #one tenth
    file_string.gsub!("\xE2\x85\x93".force_encoding("ASCII-8BIT"), '1/3')    #one third
    file_string.gsub!("\xE2\x85\x94".force_encoding("ASCII-8BIT"), '2/3')    #two third
    file_string.gsub!("\xE2\x85\x95".force_encoding("ASCII-8BIT"), '1/5')    #one fifth
    file_string.gsub!("\xE2\x85\x96".force_encoding("ASCII-8BIT"), '2/5')    #two fifth
    file_string.gsub!("\xE2\x85\x97".force_encoding("ASCII-8BIT"), '3/5')    #three fifth
    file_string.gsub!("\xE2\x85\x98".force_encoding("ASCII-8BIT"), '4/5')    #four fifth
    file_string.gsub!("\xE2\x85\x99".force_encoding("ASCII-8BIT"), '1/6')    #one sixth
    file_string.gsub!("\xE2\x85\x9A".force_encoding("ASCII-8BIT"), '5/6')    #five sixth
    file_string.gsub!("\xE2\x85\x9B".force_encoding("ASCII-8BIT"), '1/8')    #one eighth
    file_string.gsub!("\xE2\x85\x9C".force_encoding("ASCII-8BIT"), '3/8')    #three eighth
    file_string.gsub!("\xE2\x85\x9D".force_encoding("ASCII-8BIT"), '5/8')    #five eighth
    file_string.gsub!("\xE2\x85\x9E".force_encoding("ASCII-8BIT"), '7/8')    #seven eighth
    file_string.gsub!("\xC2\xbc".force_encoding("ASCII-8BIT"), '1/4') # one quarter
    file_string.gsub!("\xC2\xbd".force_encoding("ASCII-8BIT"), '1/2') # one half
    file_string.gsub!("\xC2\xbe".force_encoding("ASCII-8BIT"), '3/4') # three quarters
    file_string.gsub!("\xCA\xbf".force_encoding("ASCII-8BIT"), "'")   # c-single quote
    file_string.gsub!("\xCC\xa8".force_encoding("ASCII-8BIT"), '')    # modifier - under curve
    file_string.gsub!("\xCC\xb1".force_encoding("ASCII-8BIT"), '')    # modifier - under line
    file_string.gsub!("\xEF\xBF\xBC".force_encoding("ASCII-8BIT"), '')    # unknown
    file_string.gsub!("\xEF\xBF\xBD".force_encoding("ASCII-8BIT"), '')    # unknown

    file_string.gsub! /\r\n/, "\n"
    file_string.gsub! /\n\r/, "\n"
    file_string.gsub! /\r/, "\n"
    file_string.gsub! /\n/, "\007"
  
    file_string.gsub! /<EM STYLE="BOLD">/, '<em style="bold">'
    file_string.gsub! /<\/EM>/, "</em>"
    file_string.gsub! /&AMP;/, "&amp;"
    file_string.gsub! /<P>/, "<p>"
    file_string.gsub! /<\/P>/, "</p>"
  
    file_string.gsub! '<em style="bold">  </em>', ""
    #    file_string.gsub! '<p> <em style="bold">', '<p class="hl2_chapterhead">'
    #    file_string.gsub! '</em> </p>', "</p>"
    file_string.gsub! '{"hl2_chapterhead"=>"', ""
    file_string.gsub! '<p> <em style="bold">', '<p>{"hl2_chapterhead"=>"'
    file_string.gsub! '</em> </p>', '"}</p>'
    file_string.gsub! '<em style="bold">', ""
    file_string.gsub! '<em style="italic">', ""
    file_string.gsub! '</em>', ""

    file_string.gsub! '<hl2_chapterhead><p>', '<p>{"hl2_chapterhead"=>"'
    file_string.gsub! '</p></hl2_chapterhead>', '"}</p>'

    file_string.gsub!(/<!-- (.*?)\(unknown\) -->/) {replace_unknown($1)}

    file_string.gsub!(/<hl1>(.*?)<\/hl1>/) { "<hl1>#{clear_tags($1)}</hl1>" }
		file_string.gsub!(/<hl2>(.*?)<\/hl2>/) { "<hl2>#{clear_tags($1)}</hl2>" }
  
    file_string.gsub! /\007/, "\n"
    
    #file_string.force_encoding("UTF-8").gsub!(/\u9999/) {replace_unknown($1)}
#    file_string.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

    file_string
  end

  def self.replace_unknown(unicode_character)
    @@utf_table[unicode_character] || "&#x#{unicode_character}"
  end

  def self.clear_tags(text)
    text.gsub! /<.*?>/, ''
    text.lstrip
  end
end