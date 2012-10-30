require 'chronic'
require 'dti_nitf'

namespace :wescom do
  desc "Import the DTI stories"
  task :dti_import  => :environment do

    def get_files
      #news_files = File.join("/","data","archiveup",'*.xml')
      news_files = File.join("/","data","archiveup","completed","2012","10",'**','*.xml')
      #news_files = File.join("/","data","archiveup",'completed','testxml','**','*.xml')
      news_files = Dir.glob(news_files)
      news_files
    end

    def process_file(file)
      puts "Processing: #{file}"
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
        # puts "Sidebar: #{dti_story.sidebar_body}"
        # puts "Keywords: #{dti_story.keywords}"

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
        story.project_group = dti_story.project_group unless dti_story.project_group.nil?
        story.publication = Publication.find_or_create_by_name(dti_story.publication) unless dti_story.publication.nil?
        story.section = Section.find_or_create_by_name(dti_story.section) unless dti_story.section.nil?
        story.paper = Paper.find_or_create_by_name(dti_story.paper) unless dti_story.paper.nil?
        story.sidebar_body = dti_story.sidebar_body unless dti_story.sidebar_body.nil?
        if !dti_story.keywords.nil?
          dti_story.keywords.each { |x|
            keyword = story.keywords.find_or_create_by_text(x)
          }
        end
        story.frontend_db = "DTI"

        if !dti_story.media.nil?
          #puts "Media: #{dti_story.media}"
          dti_story.media.each { |x|
            image_filename = '/data/archiveup/images_worked/' + x["media_reference"]["source"]
            if File.exists?(image_filename)
              media = story.story_images.build(:image => File.open(image_filename))
              media.publish_status = "Published"
            else
              image_filename = '/data/archiveup/images_storage/' + x["media_reference"]["source"]
              if File.exists?(image_filename)
                media = story.story_images.build(:image => File.open(image_filename))
                media.publish_status = "Attached"
              else
                puts image_filename+' does not exist'
                media = story.story_images.build
              end
            end
            media.media_id = x["media_id"]
            media.media_name = x["media_name"]
            media.media_height = x["media_reference"]["height"]
            media.media_width = x["media_reference"]["width"]
            media.media_mime_type = x["media_reference"]["mime_type"]
            media.media_source = x["media_reference"]["source"]
            media.media_printcaption = x["media_printcaption"]
            media.media_printproducer = x["media_printproducer"]
            media.media_originalcaption = x["media_originalcaption"]
            media.media_byline = x["media_byline"]
            media.media_project_group = x["media_job"]
            media.media_notes = x["media_notes"]
            media.media_status = x["media_status"]
            media.media_type = x["media_type"]
          }
        end
        
        # Attach PDF of printed page
        # ie. C01_NEWS MAIN_28-05-2010_.PDF
        if story.pubdate? and !dti_story.section.nil? and story.page?
          pdf_filename = create_pdf_filename(story.pubdate,dti_story.section,story.page)
          pdf_path = '/data/archiveup/test/'
          if File.exists?(pdf_path+pdf_filename)
            media = story.story_images.build(:image => File.open(pdf_path+pdf_filename))
          else
            media = story.story_images.build
          end
          media.media_name = pdf_filename
          media.media_type = "PagePDF"
          media.publish_status = "PagePDF"
        end

        story.save!
puts 'StoryId: '+story.id.to_s

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
        FileUtils.cp filename, '/data/archiveup/import_failed/'+file
      end
    end
    
    def create_pdf_filename(pubdate,section,page)
      pdf_filename = section+("%02d" % page)+"_NEWS MAIN_"+pubdate.strftime('%d-%m-%y')+"_.PDF"
      return pdf_filename
    end

    import_files
  end
end
