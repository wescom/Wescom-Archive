require 'chronic'
require 'dti_nitf'

namespace :wescom do
  desc "Import DTI stories from Cloud"
  task :cloud_dti_import  => :environment do

    def import_files
      files = get_files
      files.each {|file| process_file(file)}
    end

    def get_files
      news_files = File.join("/","data","archiveup",'*.xml')
      #news_files = File.join("/","data","archiveup","completed","2012",'11','*113012*.xml')
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

    def add_story(file_contents, filename)
      begin
        dti_story = ImportDtiStory.new(file_contents)
        # Output dti_story
        #puts "**** \n"+dti_story.storyname
        #dti_story.instance_variables.each do |v|
        #  puts "#{v}: #{dti_story.instance_variable_get(v)}\n"
        #end
        story = Story.new
        
        #puts "\nStoryId: #{dti_story.storyid}"
        #puts "Story Name: #{dti_story.storyname}"
        #puts "Project Group: #{dti_story.project_group}"
        story.doc_id = dti_story.storyid unless dti_story.storyid.nil?
        story.doc_name = dti_story.storyname unless dti_story.storyname.nil?
        story.project_group = dti_story.project_group unless dti_story.project_group.nil?
#story.copyright_holder = dti_story.copyright_holder unless dti_story.copyright_holder.nil?
        story.frontend_db = "DTI Cloud"

        #puts "RunDate: #{dti_story.rundate}"
        #puts "Edition Name: #{dti_story.edition_name}"
        #puts "Section: #{dti_story.pageset_name}"
        #puts "PageSet Letter: #{dti_story.pageset_letter}"
        #puts "Page: #{dti_story.page_number}"
        #puts "Paper: #{dti_story.paper}"
        story.pubdate = Chronic.parse(dti_story.rundate) unless dti_story.rundate.nil?
        story.publication = Publication.find_or_create_by_name(dti_story.edition_name) unless dti_story.edition_name.nil?
        story.section = Section.find_or_create_by_name(dti_story.pageset_name) unless dti_story.pageset_name.nil?
        story.pageset_letter = dti_story.pageset_letter unless dti_story.pageset_letter.nil?
        story.page = dti_story.page_number unless dti_story.page_number.nil?
        if !dti_story.edition_name.nil? and !dti_story.pageset_name.nil?
# ????????? check to see if this is can be more accurate now with section letter
          story.plan = Plan.find_or_create_by_import_pub_name_and_import_section_name_and_import_section_letter(dti_story.edition_name,dti_story.pageset_name,dti_story.pageset_letter)
        end
# ????????? Origin?
        #story.paper = Paper.find_or_create_by_name(dti_story.paper) unless dti_story.paper.nil?

        #puts "hl1: #{dti_story.hl1}"
        #puts "hl2: #{dti_story.hl2}"
        #puts "Byline: #{dti_story.byline}"
        #puts "Copy: #{dti_story.print_text}"
        #puts "Sidebar Body: #{dti_story.sidebar_body}"
        story.hl1 = dti_story.hl1 unless dti_story.hl1.nil?
        story.hl2 = dti_story.hl2 unless dti_story.hl2.nil?
        story.byline = dti_story.byline unless dti_story.byline.nil?
        story.copy = dti_story.print_text unless dti_story.print_text.nil?
        story.sidebar_body = dti_story.sidebar_body unless dti_story.sidebar_body.nil?
# ?????????
        story.tagline = dti_story.tagline unless dti_story.tagline.nil?

        #puts "Keywords: #{dti_story.keywords}"
        if !dti_story.keywords.nil?
          dti_story.keywords.each { |x|
            keyword = story.keywords.find_or_create_by_text(x)
          }
        end

        if !dti_story.media_list.nil?
          dti_story.media_list.each { |x|
            #puts "*** Media Item: #{x}"
            image_filename = '/data/archiveup/images_worked/' + x["FileHeaderName"] + x["FileTypeExtension"]
            if File.exists?(image_filename)
              media = story.story_images.build(:image => File.open(image_filename))
              #media.publish_status = "Published"
            else
              image_filename = '/data/archiveup/images_storage/' + x["FileHeaderName"] + x["FileTypeExtension"]
              if File.exists?(image_filename)
                media = story.story_images.build(:image => File.open(image_filename))
                #media.publish_status = "Attached"
              else
                image_filename = '/WescomArchive/archiveup/images_storage/' + x["FileHeaderName"] + x["FileTypeExtension"]
                if File.exists?(image_filename)
                  media = story.story_images.build(:image => File.open(image_filename))
                  #media.publish_status = "Attached"
                else
                  puts image_filename+' does not exist'
                  media = story.story_images.build
                end
              end
            end

            media.media_id = x["FileHeaderId"]
            media.media_name = x["FileHeaderName"]
            media.media_height = x["Depth"]
            media.media_width = x["Width"]
            #media.media_mime_type = x["mime_type"]
            media.media_source = x["Source"]
            media.media_printcaption = x["PrintCaption"]
            media.media_webcaption = x["OriginalIPTCCaption"]
            #media.media_printproducer = x["media_printproducer"]
            media.media_originalcaption = x["UserDefinedText1"]
            media.media_byline = x["Byline"]
            media.media_project_group = x["Job"]
            media.media_notes = x["Notes"]
            media.media_status = x["StatusName"]
            media.media_type = x["FileTypeExtension"].gsub! '.', ''

            media.byline_title = x["BylineTitle"]
            media.deskname = x["DeskName"]
            media.priority = x["PriorityName"]
            if x["PriorityName"] == 'Web Ready'
              media.publish_status = "Published"
            else
              media.publish_status = "Attached"
            end
            media.created_date = x["CreatedDate"]
            media.last_refreshed_time = x["LastRefreshedTime"]
            media.expire_date = x["ExpireDate"]
            #media.related_stories = x["RelatedStoriesList"]
          }
        end
        story.save!
        story.index!
        #puts 'StoryId: '+story.id.to_s

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
