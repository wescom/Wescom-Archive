require 'chronic'

namespace :wescom do
  desc "Import all the SII stories"
  task :sii_import  => :environment do
    def count_stories_in_file(input_file)
      counter = 0
      File.open(input_file, "r") do |infile|
        while line = infile.gets
          if line =~ /^=== END OF STORY ===/
            counter += 1
        end
      end
      counter
    end
  end

  def split_file_into_multiple_pieces(file, counter)
    #Subracting 1 from the counter length for csplit to work correctly. 
    counter -= 1
    news_files = File.join("/","data","archiveup","sii_stories","news_stories")
    Dir.chdir(news_files)
    system "csplit -s -f story_`date '+%H_%M_%S'`_ #{file.split("/")[7]} -n5 #{file} \"/^=== END OF STORY ===/+1\" {#{counter}}"
    sleep 2   # Need to wait 2 seconds. system too fast to increment seconds in filename
    #puts file + " - news_stories contents: " + Dir.entries(news_files).to_s
  end

  def get_files
    news_files = File.join("/","data","archiveup","sii_stories","news_stories","story*")
    news_files = Dir.glob(news_files)
    return_files = Dir.glob(news_files)
  end

  def process_file(file)
    File.open(file, "rb") do |infile|
      puts "Processing: #{file}"
      file_contents = infile.read
      if file_contents.size != 0
        clean_text = cleanup_text(file_contents)
        add_story(clean_text)
      end
      remove_storyfile(file)
    end
  end
  
  def remove_storyfile(file)
    delete_result = File.delete(file)
#    puts file + " deleted.  Result: " + delete_result.to_s
  end

  def cleanup_text(text)
    #remove ^M line ending
    text.gsub!("\015", '')

    #Remove the elements we do not need
    text.gsub!(/^LG:?.+/,'')
    text.gsub!(/^AT:?.+/,'')
    text.gsub!(/^GR:?.+/,'')
    text.gsub!(/^PA:?.+/,'')
    text.gsub!(/^CP:?.+/,'')

    #Remove text we do not need
    text.gsub!('pu,byline ','')
    text.gsub!('pu,edtext ','')
    text.gsub!('pu,newstext ','')
    text.gsub!('pu,edtext ','')

    #Fix the Text elements with Empty attributes. 
    text.gsub!(/BYLINE\s*\(\)/,'BYLINE (BLANK)')
    text.gsub!(/TOPIC\s*\(\)/,'TOPIC (BLANK)')
    text.gsub!(/HEADLINE\s*\(\)/,'HEADLINE (BLANK)')

    #Remove empty HD elemets.
    #text.gsub!(/HD:\s*([\w+\s]\n)/,'')

    #Replace the HD Element at the beginning of a line with a <p>HD
    #text.gsub!(/^HD/,'<p>HD')

    #Replace the three spaces with pargraph tags
    text.gsub!(/\ \ \ /,'</p><p>')

    text.gsub!(/^=== END OF STORY ===/,'</p>')

    tag_headlines(text)
    strip_byline_paragraph(text)
    remove_newlines(text)

    text
  end

  def add_story(text)
    headline =  /headline \((.*?)\)/i.match(text)
    byline = /byline \((.*?)\)/i.match(text)
    topic = /topic \((.*?)\)/i.match(text)
    keyword = /keyword \((.*?)\)/i.match(text)
    pagedesc = /pagedesc \((.*?)\)/i.match(text)
    pagedate = /pagedate \((.*?)\)/i.match(text)
    pagedate = Chronic.parse(pagedate[1])
    copy = /<p>.+<\/p>/.match(text)

    #puts "\n\nHeadline: #{headline[1] unless headline.nil? }"
    #puts "Byline: #{byline[1] unless byline.nil?}"
    #puts "Topic: #{topic[1] unless topic.nil?}"
    #puts "Keyword: #{keyword[1] unless keyword.nil?}"
    #puts "Page Description: #{pagedesc[1] unless pagedesc.nil?}"
    #puts "Page Date: #{pagedate.to_s}"
    #puts "Copy: #{copy[0] unless copy.nil?}\n\n"

    story = Story.new
    story.hl1 = headline[1] unless headline.nil?
    story.pubdate = pagedate.to_s unless pagedate.nil?
    story.byline = byline[1] unless byline.nil?
    story.page = pagedesc[1] unless pagedesc.nil?
    story.copy = copy[0] unless copy.nil?
    story.frontend_db = "SII"
    story.save
    keywords = keyword[1].split
    keywords.each do |keyword|
      find_keyword = Keyword.find_or_create_by_text(keyword)
      story.keywords << find_keyword
    end
    story.save
#puts "StoryID: "+story.id.to_s
  end

  def tag_headlines(text)
    start = text.index('HD: ')
    text_end = text.length
    while !start.nil?
      stop = text[start...text_end].index(/\n/)
      if !stop.nil?
        head_text = text[start...start+stop]
        head_text.gsub! "HD: ", '<p></p><p class="hl2_chapterhead">'
        text.gsub! text[start...start+stop], head_text+'</p><p>'
        if text.index('HD: ')   # Any more occurances?
          start = text.index('HD: ')
        else
          return text
        end
      else
        return text
      end
    end
    text
  end

  def strip_byline_paragraph(text)
    start = text.index('BY: ')
    text_end = text.length
    if !start.nil?
      stop = text[start...text_end].index('The Bulletin')
      if !stop.nil?
        byline_text = text[start...start+stop+12]
        text.gsub! text[start...start+stop+12], ''
      else
        stop = text[start...text_end].index('Bulletin Staff Reporter')
        if !stop.nil?
          byline_text = text[start...start+stop+23]
          text.gsub! text[start...start+stop+23], ''
        end        
      end
    end
    text
  end

  def remove_newlines(text)
    text.gsub!(/\n/,'')
  end

  def find_sii_files_in_directory
    sii_files = File.join("/","data","archiveup","sii_stories",'test.txt')
    sii_files = Dir.glob(sii_files)
    sii_files
  end

  def split_and_count_files(input_file)
    count = count_stories_in_file(input_file)
    split_file_into_multiple_pieces(input_file,count)
    puts "File: #{input_file} Story Count: #{count}"
  end

  def import_files
    files = get_files
    files.each {|file| process_file(file)}
  end

  sii_files = find_sii_files_in_directory
  sii_files.each {|x| split_and_count_files(x)}
  import_files
  end
end
