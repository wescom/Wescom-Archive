require 'chronic'
require 'dti_nitf'

#logger           = Logger.new(STDOUT)
#logger.level     = Logger::INFO
#Rails.logger     = logger

namespace :wescom do
  desc "Import DTI stories from Cloud"
  task :cloud_dti_import  => :environment do

    def import_files
      files = get_files
      files.each {|file| process_file(file)}
    end

    def get_files
      news_files = File.join("/","WescomArchive","archiveup","cloud_dti_import",'*.xml')
      #news_files = File.join("/","WescomArchive","archiveup","import_failed",'Beer*.xml')
      #news_files = File.join("/","WescomArchive","archiveup",'completed','**','*.xml')
      news_files = Dir.glob(news_files)
      news_files
    end

    def process_file(file)
      if furniture_story?(file)
        puts "Ignoring Furniture file: #{file}"
        filename = File.basename(file)
        file_year  = Time.now.year.to_s
        dirname = '/WescomArchive/archiveup/completed/'+file_year+'/furniture/'
        FileUtils.mkdir_p(dirname) unless File.exists?(dirname)
        FileUtils.mv file, dirname+filename
      else
        if comic_story?(file)
          puts "Ignoring Comic file: #{file}"
          filename = File.basename(file)
          file_year  = Time.now.year.to_s
          dirname = '/WescomArchive/archiveup/completed/'+file_year+'/comics/'
          FileUtils.mkdir_p(dirname) unless File.exists?(dirname)
          FileUtils.mv file, dirname+filename
        else
          if saxotech_story?(file)
            puts "Ignoring Saxotech file: #{file}"
            filename = File.basename(file)
            file_year  = Time.now.year.to_s
            dirname = '/WescomArchive/archiveup/completed/'+file_year+'/saxotech/'
            FileUtils.mkdir_p(dirname) unless File.exists?(dirname)
            FileUtils.mv file, dirname+filename
          else
            puts "Processing: #{file}"
            File.open(file, "rb") do |infile|
              file_contents = infile.read
              next if file_contents.size == 0
              add_story(file_contents, file)
            end
          end
        end
      end
    end

    def add_story(file_contents, filename)
      begin
        dti_story = ImportDtiStory.new(file_contents)
        story = Story.new
        #puts "\nStoryId: #{dti_story.storyid}"
        #puts "Story Name: #{dti_story.storyname}"
        #puts "Project Group: #{dti_story.project_group}"
        story.doc_id = dti_story.storyid unless dti_story.storyid.nil?
        story.doc_name = dti_story.storyname unless dti_story.storyname.nil?
        story.project_group = dti_story.project_group unless dti_story.project_group.nil?
        story.origin = dti_story.origin unless dti_story.origin.nil?
        story.categoryname = dti_story.categoryname unless dti_story.categoryname.nil?
        story.subcategoryname = dti_story.subcategoryname unless dti_story.subcategoryname.nil?
        story.frontend_db = "DTI Cloud"
        story.memo = dti_story.memo unless dti_story.memo.nil?
        story.notes = dti_story.notes unless dti_story.notes.nil?
        story.expiredate = dti_story.expiredate unless dti_story.expiredate.nil?
        if dti_story.web_published_at.nil?
          story.web_published_at = dti_story.publish_to_web_datetime unless dti_story.publish_to_web_datetime.nil?
        else
          story.web_published_at = dti_story.web_published_at unless dti_story.web_published_at.nil?
        end
        puts story.web_published_at

        #puts "RunDate: #{dti_story.rundate}"
        #puts "Edition Name: #{dti_story.edition_name}"
        #puts "Section: #{dti_story.pageset_name}"
        #puts "PageSet Letter: #{dti_story.pageset_letter}"
        #puts "Page: #{dti_story.page_number}"
        #puts "Paper: #{dti_story.paper}"
        #puts "PubNum: #{dti_story.web_pubnum}"
        story.pubdate = Chronic.parse(dti_story.rundate) unless dti_story.rundate.nil?
        story.publication = Publication.find_or_create_by_name(dti_story.edition_name) unless dti_story.edition_name.nil?
        story.section = Section.find_or_create_by_name(dti_story.pageset_name) unless dti_story.pageset_name.nil?
        story.pageset_letter = dti_story.pageset_letter unless dti_story.pageset_letter.nil?
        story.page = dti_story.page_number unless dti_story.page_number.nil? unless dti_story.pageset_letter.nil?
        story.paper = Paper.find_or_create_by_name(dti_story.paper) unless dti_story.paper.nil?
        story.web_pubnum = dti_story.web_pubnum unless dti_story.web_pubnum.nil?
        if !dti_story.edition_name.nil? and !dti_story.pageset_name.nil? and !dti_story.pageset_letter.nil?
          story.plan = Plan.find_or_create_by_import_pub_name_and_import_section_name_and_import_section_letter(dti_story.edition_name,dti_story.pageset_name,dti_story.pageset_letter)
        else
          # "*** pageset_letter nil ***"
          story.plan = Plan.find_or_create_by_import_pub_name_and_import_section_name(dti_story.edition_name,dti_story.pageset_name)
        end
        #puts "Plan: " + story.plan.id.to_s

        #puts "hl1: #{dti_story.hl1}"
        #puts "hl2: #{dti_story.hl2}"
        #puts "Byline: #{dti_story.byline}"
        #puts "Copy: #{dti_story.print_text}"
        #puts "Sidebar Body: #{dti_story.sidebar_body}"
        story.hl1 = dti_story.hl1 unless dti_story.hl1.nil?
        story.hl2 = dti_story.hl2 unless dti_story.hl2.nil?
        story.byline = dti_story.byline unless dti_story.byline.nil?
        story.copy = dti_story.print_text unless dti_story.print_text.nil?
        story.sidebar_body = dti_story.toolbox1 unless dti_story.toolbox1.nil?
        story.tagline = dti_story.tagline unless dti_story.tagline.nil?
        story.web_hl1 = dti_story.web_hl1 unless dti_story.web_hl1.nil?
        story.web_hl2 = dti_story.web_hl2 unless dti_story.web_hl2.nil?
        story.web_text = dti_story.web_text unless dti_story.web_text.nil?
        story.toolbox2 = dti_story.toolbox2 unless dti_story.toolbox2.nil?
        story.toolbox3 = dti_story.toolbox3 unless dti_story.toolbox3.nil?
        story.toolbox4 = dti_story.toolbox4 unless dti_story.toolbox4.nil?
        story.toolbox5 = dti_story.toolbox5 unless dti_story.toolbox5.nil?
        story.web_summary = dti_story.web_summary unless dti_story.web_summary.nil?
        story.kicker = dti_story.kicker unless dti_story.kicker.nil?
        story.htmltext = dti_story.htmltext unless dti_story.htmltext.nil?
        story.videourl = dti_story.videourl unless dti_story.videourl.nil?
        story.alternateurl = dti_story.alternateurl unless dti_story.alternateurl.nil?
        story.map = dti_story.map unless dti_story.map.nil?
        story.caption = dti_story.caption unless dti_story.caption.nil?

        #puts "Keywords: #{dti_story.keywords}"
        if !dti_story.keywords.nil?
          if dti_story.keywords.kind_of?(Array)
            dti_story.keywords.each { |x|
              keyword = story.keywords.find_or_create_by_text(x)
            }
          else
            keyword = story.keywords.find_or_create_by_text(dti_story.keywords)
          end
        end

        if !dti_story.media_list.nil?
          dti_story.media_list.each { |x|
            #puts "*** Media Item: #{x}"
            image_filename = '/WescomArchive/archiveup/images_cloud/'
            image_filename = image_filename + x["FileHeaderName"] unless x["FileHeaderName"].nil?
            image_filename = image_filename + x["FileTypeExtension"] unless x["FileTypeExtension"].nil?

            if !x["FileHeaderName"].nil? and File.exists?(image_filename)
              media = story.story_images.build(:image => File.open(image_filename))
            else
              puts image_filename+' does not exist'
              media = story.story_images.build
            end

            media.media_id = x["FileHeaderId"] unless x["FileHeaderId"].nil?
            media.media_name = x["FileHeaderName"] unless x["FileHeaderName"].nil?
            media.media_height = x["Depth"] unless x["Depth"].nil?
            media.media_width = x["Width"] unless x["Width"].nil?
            #media.media_mime_type = x["mime_type"] unless x["mime_type"].nil?
            media.media_source = x["Source"] unless x["Source"].nil?
            media.media_webcaption = x["OriginalIPTCCaption"] unless x["OriginalIPTCCaption"].nil?
            #puts media.media_webcaption

            if !x["RunList"].nil? and !x["RunList"]["RunInfoItem"].nil?
              if x["RunList"]["RunInfoItem"].kind_of?(Array)
                x["RunList"]["RunInfoItem"].each { |y|
                  media.media_printcaption = y["PrintCaption"] unless x["PrintCaption"].nil?
                }
              else
                media.media_printcaption = x["RunList"]["RunInfoItem"]["PrintCaption"] unless x["RunList"]["RunInfoItem"]["PrintCaption"].nil?
              end
            end
            #puts media.media_printcaption

            media.media_originalcaption = x["UserDefinedText1"] unless x["UserDefinedText1"].nil?
            media.media_byline = x["Byline"] unless x["Byline"].nil?
            media.media_project_group = x["Job"] unless x["Job"].nil?
            media.media_notes = x["Notes"] unless x["Notes"].nil?
            media.media_status = x["StatusName"] unless x["StatusName"].nil?
            media.media_category = x["CategoryName"] unless x["CategoryName"].nil?
            media.media_type = x["FileTypeExtension"].gsub(/\./, '') unless x["FileTypeExtension"].nil?
            media.byline_title = x["BylineTitle"] unless x["BylineTitle"].nil?
            media.deskname = x["DeskName"] unless x["DeskName"].nil?
            media.priority = x["PriorityName"] unless x["PriorityName"].nil?

            if !x["RunList"].nil? or x["PriorityName"] == 'Web Ready'
              media.publish_status = "Published"
            else
              media.publish_status = "Attached"
            end
            media.created_date = x["CreatedDate"] unless x["CreatedDate"].nil?
            media.last_refreshed_time = x["LastRefreshedTime"] unless x["LastRefreshedTime"].nil?
            media.expire_date = x["ExpireDate"] unless x["ExpireDate"].nil?
            #media.related_stories = x["RelatedStoriesList"] unless x["RelatedStoriesList"].nil?
          }
        end
#puts "*********************"
#puts "/tmp/* ..."
#puts %x[ ls -l /tmp ]
#puts "*********************"
#puts "whoami: "+ %x[ whoami ]
#puts "*********************"

        story.save!
        story.index!
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
        
        # Move completed import file out of import folder
        file = File.basename(filename)
        file_month = ""
        file_year  = ""
        if !story.pubdate.nil?
          file_month = story.pubdate.month.to_s
          file_year  = story.pubdate.year.to_s
        else
          if !story.web_published_at.nil?
            file_month = story.web_published_at.month.to_s
            file_year  = story.web_published_at.year.to_s
          else
            file_month = "web_only"
            file_year  = Time.now.year.to_s
          end
        end
        dirname = '/WescomArchive/archiveup/completed/'+file_year+'/'+file_month+'/'
        FileUtils.mkdir_p(dirname) unless File.exists?(dirname)
        FileUtils.mv filename, dirname+file

      rescue Exception => e
        puts "Failed to Process File: #{filename}\n Error: #{e}\n\n"
        file = File.basename(filename)
#        FileUtils.mv filename, '/WescomArchive/archiveup/import_failed/'+file
      end
    end
    
    def furniture_story?(file)
      fileupper = file.upcase
       if !(fileupper =~ /\D\da? FURN/).nil? or !(fileupper =~ /\D\da?FURN/).nil? or 
         !(fileupper =~ /FURN\D\da?/).nil? or !(fileupper =~ /FURN \D\da?/).nil? or 
         !(fileupper =~ /FURNITURE\D\da?/).nil? or !(fileupper =~ /FURNITURE \D\da?/).nil?
        return true
      else
        return false
      end
    end

    def comic_story?(file)
      fileupper = file.upcase
puts fileupper
       if !(fileupper =~ /COMICS \da?/).nil?
        return true
      else
        return false
      end
    end

    def saxotech_story?(file)
      # Check whether story was imported from Saxotech
      fileupper = file.upcase
       if !(fileupper =~ /(SX-)/).nil?
        return true
      else
        return false
      end
    end

    def create_pdf_filename(pubdate,section,page)
      pdf_filename = section+("%02d" % page)+"_NEWS MAIN_"+pubdate.strftime('%d-%m-%y')+"_.PDF"
      return pdf_filename
    end

    import_files
  end
end
