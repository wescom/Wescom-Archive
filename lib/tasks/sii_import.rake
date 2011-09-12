require 'chronic'

namespace :wescom do
  desc "Import all teh SII stories"
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
    news_files = File.join(RAILS_ROOT,"news_stories")
    Dir.chdir(news_files)
    system "csplit -s -fstory#{file.split("/")[7]} -n4 #{file} \"/^=== END OF STORY ===/+1\" {#{counter}}"
  end

  def get_files
    news_files = File.join(RAILS_ROOT,"news_stories","story*")
    news_files = Dir.glob(news_files)
    return_files = Dir.glob(news_files)
  end

  def process_file(file)
    File.open(file, "rb") do |infile|
      file_contents = infile.read
      next if file_contents.size == 0
      clean_text = cleanup_text(file_contents)
      add_story(clean_text)
    end
  end

  def cleanup_text(text)
    #remove ^M line ending
    text.gsub!("\015", '')

    #Remove the elements I do not need
    text.gsub!(/^LG:?.+/,'')
    text.gsub!(/^AT:?.+/,'')
    text.gsub!(/^GR:?.+/,'')
    text.gsub!(/^PA:?.+/,'')
    text.gsub!(/^BY:?.+/,'')

    #Fix the Text elements with Empty attributes. 
    text.gsub!(/BYLINE\s*\(\)/,'BYLINE (BLANK)')
    text.gsub!(/TOPIC\s*\(\)/,'TOPIC (BLANK)')
    text.gsub!(/HEADLINE\s*\(\)/,'HEADLINE (BLANK)')

    #Remove empty HD elemets.
    #text.gsub!(/HD:\s*([\w+\s]\n)/,'')

    #Remove newlines as a test
    #

    #Replace the HD Element at teh beginning of a line with a <p>HD
    text.gsub!(/^HD/,'<p>HD')
    #Replace the three spaces with pragraph tags
    text.gsub!(/\ \ \ /,'</p><p>')

    text.gsub!(/^=== END OF STORY ===/,'</p>')

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
    story.headline = headline[1] unless headline.nil?
    story.pubdate = pagedate.to_s unless pagedate.nil?
    story.byline = byline[1] unless byline.nil?
    story.page = pagedesc[1] unless pagedesc.nil?
    story.copy = copy[0] unless copy.nil?
    story.save
    keywords = keyword[1].split
    keywords.each do |keyword|
      find_keyword = Keyword.find_or_create_by_text(keyword)
      story.keywords << find_keyword
    end
    story.save
  end

  def remove_newlines(text)
    text.gsub!(/\n/,'')
  end

  def find_sii_files_in_directory
    sii_files = File.join(RAILS_ROOT,"sii_data","*.txt")
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
