require 'chronic'
require 'dti_nitf'

namespace :wescom do
  desc "Import the DTI stories"
  task :dti_import  => :environment do

    def get_files
      news_files = File.join("/","archive_data","test",'**','*.xml')
      #news_files = File.join("/","archive_data","2011",'**','*.xml')
      news_files = Dir.glob(news_files)
      news_files
    end

    def process_file(file)
      #puts "Processing: #{file}"
      File.open(file, "rb") do |infile|
        file_contents = infile.read
        next if file_contents.size == 0
        add_story(file_contents, file)
      end
    end

    def import_files
      files = get_files
      files.each {|file| process_file(file)}
    end

    def add_story(file_contents, filename)
      begin
        dti_story = ImportStory.new(file_contents)
        # puts "\nHl1: #{dti_story.hl1}"
        # puts "Hl2: #{dti_story.hl2}"
        # puts "Byline: #{dti_story.byline}"
        # puts "Page Date: #{dti_story.pub_date}"
        # puts "Page: #{dti_story.page}"
        # puts "Paper: #{dti_story.paper}"
        # puts "Body Length: #{dti_story.body.length}" unless dti_story.body.nil?
        # puts "Copy: \n#{dti_story.body}"
        # puts "Media: #{dti_story.media}"
        # puts "Sidebar: #{dti_story.sidebar_body}"

        story = Story.new
        story.hl1 = dti_story.hl1 unless dti_story.hl1.nil?
        story.hl2 = dti_story.hl2 unless dti_story.hl2.nil?
        story.tagline = dti_story.tagline unless dti_story.tagline.nil?
        story.pubdate = Chronic.parse(dti_story.pub_date) unless dti_story.pub_date.nil?
        story.page = dti_story.page unless dti_story.page.nil?
        story.byline = dti_story.byline unless dti_story.byline.nil?
        story.copy = dti_story.body unless dti_story.body.nil?
        story.doc_id = dti_story.doc_id unless dti_story.doc_id.nil?
        story.copyright_holder = dti_story.copyright_holder unless dti_story.copyright_holder.nil?
        story.doc_name = dti_story.doc_name unless dti_story.doc_name.nil?
        story.publication = Publication.find_or_create_by_name(dti_story.publication) unless dti_story.publication.nil?
        story.section = Section.find_or_create_by_name(dti_story.section) unless dti_story.section.nil?
        story.paper = Paper.find_or_create_by_name(dti_story.paper) unless dti_story.paper.nil?
        story.sidebar_body = dti_story.sidebar_body unless dti_story.sidebar_body.nil?
        story.save!

        if dti_story.correction?
          puts "Correction for Original Story #" + dti_story.original_story_id.to_s
          original_story = Story.find_by_doc_id(dti_story.original_story_id)
          if original_story
            #puts original_story.class
            correction_link = original_story.correction_links.build(:correction_id => story.id)
            #puts correction_link.class
            correction_link.save
          else
            puts "No original story found in database"
          end
        end
      rescue Exception => e
        puts "Failed to Process File: #{filename}\n Error: #{e}\n\n"
        file = File.basename(filename)
        FileUtils.cp filename, '/archive_data/import_failed/'+file
      end
    end

    import_files
  end
end
