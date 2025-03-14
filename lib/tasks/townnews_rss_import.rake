require 'nokogiri'
require 'open-uri'

namespace :townnews do

    task :rss_import => :environment do

        def import_files
            desc "Import TownNews RSS story/Image export"

            # rake task accepts a date variable to force import of dates other than today. ie: bundle exec rake townnews:rss_import date=04/16/2020
            if ENV['date'].nil?
              find_date = Date.today.strftime('%m/%d/%Y')
              puts "No date requested, defaulting to todays date: " + find_date
              puts "   - to request importing of specific date, add date=MM/DD/YYYY"
              puts "   - to request importing of date range, add 'startdate=MM/DD/YYYY' AND 'stopdate=MM/DD/YYYY'" 
            else
              find_date = ENV['date']
              puts "Date requested: " +ENV['date']
            end

            # fyi... TownNews will only export stories 'published' based on startdate AND starttime. 
            # If a story does not publish until an hour later than it will not be included in the rss feed.
            url = 'https://www.bendbulletin.com/search/?q=&t=article&l=100&s=start_time&sd=desc&d='+find_date+'&c=&nk=%23tncen&fulltext=alltext&f=rss&altf=archive'
            xml_raw = Nokogiri::XML(open(url), nil, "UTF-8").to_s
            xml_raw = remove_tags(xml_raw)
            xml_parsed = Crack::XML.parse(xml_raw)

            xml_tag = xml_parsed["xml"]
            item_tags = Array.wrap(xml_parsed["xml"]["item"])

            num_stories = 0
            num_images = 0
            warnings_log = ""
            errors_log = ""

            puts "\nImporting for date: " + find_date
            puts "----------------------------------"
            item_tags.each do |item|
                #puts "Importing "+item["uuid"]+" - "+item["headline"]

                # convert uuid string to binary data for storage
                #uuid = item["uuid"].scan(/[0-9a-f]{4}/)     # remove '-'s and split uuid into 4 character array items
                #uuid = uuid.map { |x| x.to_i(16) }          # convert each item in uuid array into 16bit integer
                #uuid = uuid.pack('n*')                      # pack array into a binary sequence for storing

                uuid = s_to_uuid(item["uuid"])
                story = Story.find_or_create_by(uuid: uuid, frontend_db: "TownNews")
                story.uuid = uuid
                #puts story.id
                #puts uuid_to_s(story.uuid)

                story.doc_id = 0            # TownNews does not have an id, uses uuid instead                
                story.doc_name = ""         # TownNews cannot export slug in an RSS feed
                story.frontend_db = "TownNews"
                story.weblink = item["link"] unless item["link"].nil?

                story.origin = item["asset_source"] unless item["asset_source"].nil?
                story.pubdate = (item["pubDate"].nil? ? Time.now : item["pubDate"])

                # print data is not accessible from a TownNews RSS feed
                #story.publication = Publication.find_or_create_by(name: dti_story.edition_name) unless dti_story.edition_name.nil?
                story.web_pubnum = get_pubnum(xml_tag["title"])

                story.hl1 = item["headline"].truncate(250) unless item["headline"].nil?
                story.hl2 = item["subheadline"].truncate(250) unless item["subheadline"].nil?
                #puts "\n" + story.pubdate.strftime('%m/%d/%Y') + '   Importing Story: '+story.hl1

                byline = item["byline"]
                unless byline.nil?
                    byline = byline.split(/\n+/) unless byline.nil?   # split byline into array by carriage returns
                    paper = byline[1] unless byline[1].nil?
                    paper = paper.gsub(/<[^<>]*>/, "") unless paper.nil?      # Remove any tags from string
                    paper = paper.truncate(250).titlecase.strip unless paper.nil?
                    byline = byline[0] unless byline[0].nil?
                    byline = byline.truncate(250) unless byline.nil?
                    byline = byline.gsub(/<[^<>]*>/, "") unless byline.nil?   # Remove any tags from string
                    byline = byline.gsub(/^By /, "").titlecase.strip unless byline.nil?       # Remove 'By' from string
                else
                    byline = ""
                    paper = ""
                end
                story.byline = byline
                story.paper = Paper.find_or_create_by(name: paper) unless paper.nil?

                # import story body, truncating to max length and removing accent characters
                story.copy = item["content"].truncate(65500) unless item["content"].nil?
                story.copy = story.copy.unaccent unless story.copy.nil?
                story.copy = cleanup_text(story.copy) unless story.copy.nil?
                #puts story.copy

                # import side_body, toolbox, extra text
                facts = ""
                asset_facts = Array.wrap(item["asset_facts"]["asset_fact"]) unless item["asset_facts"].nil?
                unless asset_facts.nil?
                    asset_facts.each do |asset_fact|
                        facts = facts + "<p><strong>" + asset_fact["fact_title"] + "</strong></p>"
                        fact_content = Array.wrap(asset_fact["fact_content"]["p"]) unless asset_fact["fact_content"].nil?
                        unless fact_content.nil?
                            fact_content.each do |p|
                                if p.is_a?(Hash)
                                    text = hash_to_tag(p)
                                else
                                    text = p
                                end
                                facts = facts + "<p>" + text + "</p>"
                            end
                            facts = facts + "<p> </p>"
                        end
                    end
                end
                story.sidebar_body = facts

                story.tagline = item["tagline"] unless item["tagline"].nil?
                story.kicker = item["kicker"] unless item["kicker"].nil?
                #story.hammer = item["hammer"] unless item["hammer"].nil?

                # import keyword records
                keywords = Array.wrap(item["keywords"]["keyword"]) unless item["keywords"].nil?
                unless keywords.nil?
                    keywords.each do |x|
                        keyword = Keyword.find_or_create_by(text: x.truncate(250))
                        story.keywords << keyword unless story.keywords.include?(keyword)
                    end
                end

                # import author records
                authors = Array.wrap(item["authors"]["author"]) unless item["authors"].nil?
                unless authors.nil?
                    authors.each do |x|
                        author = Author.find_or_create_by(name: x)
                        story.authors << author unless story.authors.include?(author)
                    end
                end

                # import section records
                sections = Array.wrap(item["sections"]["section"]) unless item["sections"].nil?
                unless sections.nil?
                    story.categoryname = sections[0] unless sections.nil?
                    sections.each do |x|
                        section = Section.find_or_create_by(name: x.truncate(250))
                        story.sections << section unless story.sections.include?(section)
                    end
                end

                # import flag records
                flags = Array.wrap(item["flags"]["flag"]) unless item["flags"].nil?
                unless flags.nil?
                    flags.each do |x|
                        flag = Flag.find_or_create_by(name: x.truncate(250))
                        story.flags << flag unless story.flags.include?(flag)
                    end
                end

                # Import images attached to story
                media_tags = Array.wrap(item["multimedia"]["media"]) unless item["multimedia"].nil?
                unless media_tags.nil?
                    media_tags = media_tags.reject { |array_item| array_item["uuid"].nil? }
                    media_tags.each do |media_tag|
                        media_uuid = s_to_uuid(media_tag["uuid"])

                        media = story.story_images.find_or_create_by(uuid: media_uuid)
                        media.uuid = media_uuid
                        if media_tag["title"].nil?
                            media.media_name = item["headline"].truncate(250)
                        else
                            media.media_name = media_tag["title"].truncate(250)
                        end
                        media.weblink = media_tag["link"] unless media_tag["link"].nil?

                        # download image and attach
                        media.image = URI.parse(media.weblink) unless media.weblink.nil?
                        media.media_width = media_tag["width"] unless media_tag["width"].nil?
                        media.media_height = media_tag["height"] unless media_tag["height"].nil?

                        media.media_source = media_tag["source"] unless media_tag["source"].nil?
                        media.media_webcaption = cleanup_text(media_tag["caption"].gsub("</p><p>","\n").gsub(/<[^<>]*>/, "")) unless media_tag["caption"].nil?
                        media.media_byline = media_tag["byline"].truncate(250) unless media_tag["byline"].nil?
                        media.media_type = File.extname(media.image_file_name).strip.downcase[1..-1] unless media.image_file_name.nil?
                        media.forsale = media_tag["forSale"] unless media_tag["forSale"].nil?

                        media.pubdate = (media_tag["pubDate"].nil? ? Time.now : media_tag["pubDate"])
                        media.publish_status = (media_tag["isPublished"] == 'true' ? "Published" : "Attached")
                        media.last_refreshed_time = media_tag["lastupdated"].nil? unless media_tag["lastupdated"].nil?

                        # import image keyword records
                        image_keywords = Array.wrap(media_tag["keywords"]["keyword"]) unless media_tag["keywords"].nil?
                        unless image_keywords.nil?
                            image_keywords.each do |x|
                                keyword = Keyword.find_or_create_by(text: x.truncate(250))
                                media.keywords << keyword unless media.keywords.include?(keyword)
                            end
                        end

                        # import image photographer 'author' records
                        image_authors = Array.wrap(media_tag["photographers"]["photographer"]) unless media_tag["photographers"].nil?
                        unless image_authors.nil?
                            image_authors.each do |x|
                                author = Author.find_or_create_by(name: x)
                                media.authors << author unless media.authors.include?(author)
                            end
                        end

                        # import image section records
                        image_sections = Array.wrap(media_tag["sections"]["section"]) unless media_tag["sections"].nil?
                        unless image_sections.nil?
                            image_sections.each do |x|
                                section = Section.find_or_create_by(name: x.truncate(250))
                                media.sections << section unless media.sections.include?(section)
                            end
                        end

                        # import image flag records
                        image_flags = Array.wrap(media_tag["flags"]["flag"]) unless media_tag["flags"].nil?
                        unless image_flags.nil?
                            image_flags.each do |x|
                                flag = Flag.find_or_create_by(name: x.truncate(250))
                                media.flags << flag unless media.flags.include?(flag)
                            end
                        end

                        media_name = media.media_name
                        media.update_attributes(uuid: s_to_uuid(media_tag["uuid"]), media_name: media_name)
                        #puts '   Image: #'+media.id.to_s + " - " + uuid_to_s(media.uuid) + " - " + media.media_name.truncate(250)
                    end
                end

                story.save!
                story.index!

                # Display imported story record
                if ((story.updated_at - story.created_at) * 24 * 60 * 60).to_i < 10
                    puts "\nCreated Story: #"+story.id.to_s + " - " + uuid_to_s(story.uuid) + " - " + story.hl1
                else
                    puts "\nUpdated Story: #"+story.id.to_s + " - " + uuid_to_s(story.uuid) + " - " + story.hl1
                end

                puts "      Errors: "+story.errors.full_messages.inspect if story.errors.present?
                num_stories += 1                        
                unless story.story_images.nil?
                    story.story_images.each do |image|
                        puts '      Image: #'+image.id.to_s + " - " + image.media_name
                        if image.image_file_size.nil?
                           puts "      *** WARNING: Imported image missing content"
                           warnings_log = warnings_log + "\nImported image missing content "
                           warnings_log = warnings_log + "\n   Story: #" + story.id.to_s + " - " + story.hl1
                           warnings_log = warnings_log + "\n   Image: #" + image.id.to_s + " - " + image.media_name
                        end
                        num_images += 1                        
                    end
                end
            end
            puts "\nTotal imported for date " + find_date
            puts "-------------------"
            puts "  Stories: " + num_stories.to_s
            puts "  Images:  " + num_images.to_s
            
            # Display Warnings\Errors
            if warnings_log.length > 0
                puts "\n Warnings:"
                puts "-------------------" + warnings_log
            end
            if errors_log.length > 0
                puts "\n Errors:"
                puts "-------------------" + errors_log
            end
            puts "\n\n"
        end


        def get_pubnum(text)
            # find Location record that text includes short_url_newspaper_name
            pubnum = ""
            locations = Location.all
            locations.each do |location|
                if text.include?(location.short_url_newspaper_name) 
                    pubnum = location.id
                    break
                end
            end
            return pubnum
        end

        def uuid_to_s(uuid)
            uuid_text = uuid.unpack('n*').map { |x| x.to_s(16) }
            return uuid_text[0]+uuid_text[1]+"-"+uuid_text[2]+"-"+uuid_text[3]+"-"+uuid_text[4]+"-"+uuid_text[5]+uuid_text[6]+uuid_text[7]
        end

        def s_to_uuid(uuid)
            # convert uuid string into binary data for storage
            uuid = uuid.scan(/[0-9a-f]{4}/)             # remove '-'s and split uuid into 4 character array items
            uuid = uuid.map { |x| x.to_i(16) }          # convert each item in uuid array into 16bit integer
            uuid = uuid.pack('n*')                      # pack array into a binary sequence for storing
            return uuid
        end

        def hash_to_tag(hash)
            string_with_tag = "<"+hash.keys[0]+">" + hash.values[0] + "</"+hash.keys[0]+">"
            return string_with_tag 
        end

        def remove_tags(file_string)
            file_string.gsub!("<em>", '')
            file_string.gsub!("</em>", '')

            file_string
        end    
        
        def cleanup_text(file_string)
          file_string.gsub!("\xEF\xBB\xBF", ' ')    #BOMS
          file_string.gsub!("\xE2\x80\xA8", ' ')    #BOMS
          file_string.gsub!("\xE2\x80\x80", ' ')    #Unknown
          file_string.gsub!("\xE2\x80\x81", ' ')    #Unknown
          file_string.gsub!("\xE2\x80\x82", ' ')    #EM Space
          file_string.gsub!("\xE2\x80\x83", ' ')    #EM Space
          file_string.gsub!("\xE2\x81\x84", '/')    #BOMS
          file_string.gsub!("\xE2\x80\x85", '')    #Unknown
          file_string.gsub!("\xE2\x80\x86", '')    #Unknown
          file_string.gsub!("\xE2\x80\x87", '')    #Unknown
          file_string.gsub!("\xE2\x80\x88", '')    #Unknown
          file_string.gsub!("\xE2\x80\x89", ' ')   #BOMS
          file_string.gsub!("\xE2\x80\x8A", '')    #Unknown
          file_string.gsub!("\xE2\x80\x8B", '')    #Unknown
          file_string.gsub!("\xE2\x80\x8C", '')    #Unknown
          file_string.gsub!("\xE2\x80\x8D", '')    #Unknown
          file_string.gsub!("\xE2\x80\x8E", '')    #Unknown
          file_string.gsub!("\xE2\x80\x8F", '')    #Unknown
          file_string.gsub!("\xC2\x82", ',')   # High code comma
          file_string.gsub!("\xC2\x84", ',,')  # High code double comma
          file_string.gsub!("\xC2\x85", '...') # Tripple dot
          file_string.gsub!("\xC2\x88", '^')   # High carat
          file_string.gsub!("\xC2\x91", "'")   # Forward single quote
          file_string.gsub!("\xC2\x92", "'")   # Reverse single quote
          file_string.gsub!("\xC2\x93", '"')   # Forward double quote
          file_string.gsub!("\xC2\x94", '"')   # Reverse double quote
          file_string.gsub!("\xC2\x95", ' ')
          file_string.gsub!("\xC2\x96", '-')   # High hyphen
          file_string.gsub!("\xC2\x97", '--')  # Double hyphen
          file_string.gsub!("\xC2\x99", ' ')
          file_string.gsub!("\xC2\xa0", ' ')
          file_string.gsub!("\xC2\xa6", '|')   # Split vertical bar
          file_string.gsub!("\xC2\xab", '<<')  # Double less than
          file_string.gsub!("\xC2\xbb", '>>')  # Double greater than
          file_string.gsub!("\xE2\x80\xA9", '')    #
          file_string.gsub!("\xE2\x80\xB2", '')    #
          file_string.gsub!("\xE2\x85\x90", ' 1/7')    #one seventh
          file_string.gsub!("\xE2\x85\x91", ' 1/9')    #one ninth
          file_string.gsub!("\xE2\x85\x92", ' 1/10')    #one tenth
          file_string.gsub!("\xE2\x85\x93", ' 1/3')    #one third
          file_string.gsub!("\xE2\x85\x94", ' 2/3')    #two third
          file_string.gsub!("\xE2\x85\x95", ' 1/5')    #one fifth
          file_string.gsub!("\xE2\x85\x96", ' 2/5')    #two fifth
          file_string.gsub!("\xE2\x85\x97", ' 3/5')    #three fifth
          file_string.gsub!("\xE2\x85\x98", ' 4/5')    #four fifth
          file_string.gsub!("\xE2\x85\x99", ' 1/6')    #one sixth
          file_string.gsub!("\xE2\x85\x9A", ' 5/6')    #five sixth
          file_string.gsub!("\xE2\x85\x9B", ' 1/8')    #one eighth
          file_string.gsub!("\xE2\x85\x9C", ' 3/8')    #three eighth
          file_string.gsub!("\xE2\x85\x9D", ' 5/8')    #five eighth
          file_string.gsub!("\xE2\x85\x9E", ' 7/8')    #seven eighth
          file_string.gsub!("\xC2\xbc", ' 1/4') # one quarter
          file_string.gsub!("\xC2\xbd", ' 1/2') # one half
          file_string.gsub!("\xC2\xbe", ' 3/4') # three quarters
          file_string.gsub!("\xCA\xbf", "'")   # c-single quote
          file_string.gsub!("\xCC\xa8", '')    # modifier - under curve
          file_string.gsub!("\xCC\xb1", '')    # modifier - under line
          file_string.gsub!("\xEF\xBF\xBC", '')    # unknown
          file_string.gsub!("\xEF\xBF\xBD", '')    # unknown
          file_string.gsub!("\xEF\xB8\x8F", '')    # unknown
          file_string.gsub!("\xEF\x80\x85", '')    # unknown
          file_string.gsub!("\xEF\x80\x86", '')    # unknown
          file_string.gsub!("\xEF\x80\x87", '')    # unknown
          file_string.gsub!("\xEF\x80\x88", '')    # unknown
          file_string.gsub!("\xEF\x80\x89", '')    # unknown
          file_string.gsub!("\xEF\x80\x8A", '')    # unknown
          file_string.gsub!("\xEF\x80\x8B", '')    # unknown
          file_string.gsub!("\xEF\x80\x8C", '')    # unknown
          file_string.gsub!("\xEF\x80\x8D", '')    # unknown
          file_string.gsub!("\xEF\x80\x8E", '')    # unknown
          file_string.gsub!("\xEF\x80\x8F", '')    # unknown
          file_string.gsub!("\xEF\x84\xA1", '')    # unknown
          file_string.gsub!("\xEF\x84\xA2", '')    # unknown
          file_string.gsub!("\xEF\x84\xA3", '')    # unknown

          return file_string
        end

# Run initial code
        # Check for startdate and stopdate range
        if !ENV['startdate'].nil? or !ENV['stopdate'].nil?
            if !ENV['startdate'].nil? and !ENV['stopdate'].nil?
                startdate = Date.strptime(ENV['startdate'], '%m/%d/%Y')
                stopdate = Date.strptime(ENV['stopdate'], '%m/%d/%Y')
                while (stopdate - startdate).to_i >= 0
                    ENV['date'] = startdate.strftime('%m/%d/%Y')
                    import_files
                    startdate = startdate + 1
                end
            else
                puts "Requested date error:"
                puts "   - to request importing of date range, add 'startdate=MM/DD/YYYY' AND 'stopdate=MM/DD/YYYY'" 
            end
        else
            import_files
        end

    end
end