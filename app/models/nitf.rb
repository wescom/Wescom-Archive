class Nitf < ActiveRecord::Base
  dir = File.dirname(__FILE__)
  @@utf_table = YAML::load_file(File.join(dir, 'lookup_table.yml'))

  def self.parse(file_string)
    @@story_string = cleanup_text(file_string)
    @@story_string
  end

  private
  def self.cleanup_text(file_string)
#    file_string.gsub! /\xef\xbb\xbf/, '' #BOMS
    file_string.gsub!("\xEF\xBB\xBF".force_encoding("ASCII-8BIT"), '')    #BOMS
    file_string.gsub! /\t/, ' '
    file_string.gsub! /([\x00-\x09])/, ''
    file_string.gsub! /([\x0B\x0C\x0E-\x1F])/, ''
  
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
    file_string.gsub! '<p> <em style="bold">', '<p>{"hl2_chapterhead"=>"'
    file_string.gsub! '</em> </p>', '}</p>'
    file_string.gsub! '<em style="bold">', ""
    file_string.gsub! '<em style="italic">', ""
    file_string.gsub! '</em>', ""
    file_string.gsub! '{"hl2_chapterhead"=>"', ""

    file_string.gsub! '<hl2_chapterhead><p>', '<p>{"hl2_chapterhead"=>"'
    file_string.gsub! '</p></hl2_chapterhead>', '"}</p>'

    file_string.gsub!(/<!-- (.*?)\(unknown\) -->/) {replace_unknown($1)}

    file_string.gsub!(/<hl1>(.*?)<\/hl1>/) { "<hl1>#{clear_tags($1)}</hl1>" }
		file_string.gsub!(/<hl2>(.*?)<\/hl2>/) { "<hl2>#{clear_tags($1)}</hl2>" }
  
    file_string.gsub! /\007/, "\n"
  
    file_string.force_encoding("UTF-8").gsub!(/\u9999/) {replace_unknown($1)}

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