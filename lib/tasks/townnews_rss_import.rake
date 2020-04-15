require 'nokogiri'
require 'open-uri'

namespace :townnews do

    task :rss_import => :environment do

        def import_files
            desc "Import TownNews RSS story/Image export"
            url = 'https://www.bendbulletin.com/search/?q="Elixir of Love"&t=article&l=100&s=start_time&sd=desc&d=03/05/2020&c=*lifestyle/arts*&nk=%23tncen&fulltext=alltext&f=rss&altf=archive'

            xml_raw = Nokogiri::XML(open(url), nil, "UTF-8").to_s
            xml_parsed = Crack::XML.parse(xml_raw)

            xml_tag = xml_parsed["xml"]
            item_tags = Array.wrap(xml_parsed["xml"]["item"])
        
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

                if story.created_at.nil?
                    puts "\n   * created at "+Time.now.strftime('%m/%d/%y %r')
                else
                    puts "\n   * updated at "+story.updated_at.strftime('%m/%d/%y %r')
                end

                story.doc_id = 0            # TownNews does not have an id, uses uuid instead                
                story.doc_name = ""         # TownNews cannot export slug in an RSS feed
                story.frontend_db = "TownNews"
                story.weblink = item["link"] unless item["link"].nil?

                story.origin = item["asset_source"] unless item["asset_source"].nil?
                story.categoryname = item["sections"]["section"] unless item["sections"].nil?
                story.pubdate = (item["pubdate"].nil? ? Time.now : item["pubdate"])

                # print data is not accessible from a TownNews RSS feed
                #story.publication = Publication.find_or_create_by(name: dti_story.edition_name) unless dti_story.edition_name.nil?
                story.web_pubnum = get_pubnum(xml_tag["title"])

                story.hl1 = item["headline"].truncate(250) unless item["headline"].nil?
                story.hl2 = item["subheadline"].truncate(250) unless item["subheadline"].nil?

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

                story.copy = item["description"].truncate(65500) unless item["description"].nil?
#                story.copy = story.copy.truncate(65500) unless item["description"].nil?

                # import side_body, toolbox, extra text
                asset_facts = Array.wrap(item["asset_facts"]) unless item["asset_facts"].nil?
                facts = ""
                unless asset_facts.nil?
                    asset_facts.each do |asset_fact|
                        fact_title = asset_fact["fact_title"].to_s
                        fact_content = asset_fact["fact_content"]
                        fact = ""
                        unless asset_facts.nil?
                            fact_content_p = ""
                            fact_content["p"].each do |p|
                                fact_content_p += "<p>"+ p + "</p>"
                            end
                            fact = "<p><strong>"+fact_title+"</strong></p>" + fact_content_p + "\n\n"
                        end
                        facts += fact 
                    end
                end
                story.sidebar_body = facts

                story.tagline = item["tagline"] unless item["tagline"].nil?
                story.kicker = item["kicker"] unless item["kicker"].nil?
                #story.hammer = item["hammer"] unless item["hammer"].nil?

                # Import images attached to story
                media_tags = Array.wrap(item["multimedia"]["media"]) unless item["multimedia"].nil?
                unless media_tags.nil?
                    media_tags.each do |media_tag|
                        media_uuid = s_to_uuid(media_tag["uuid"])

                        media = story.story_images.find_or_create_by(uuid: media_uuid)
                        media.uuid = media_uuid
                        media.media_name = media_tag["title"] unless media_tag["title"].nil?
                        media.weblink = media_tag["link"] unless media_tag["link"].nil?

                        # download image and attach
                        media.image = URI.parse(media.weblink) unless media.weblink.nil?
                        media.media_width = media_tag["width"] unless media_tag["width"].nil?
                        media.media_height = media_tag["height"] unless media_tag["height"].nil?

                        media.media_source = media_tag["source"] unless media_tag["source"].nil?
                        media.media_webcaption = media_tag["caption"].gsub("</p><p>","\n").gsub(/<[^<>]*>/, "") unless media_tag["caption"].nil?
                        media.media_byline = media_tag["byline"] unless media_tag["byline"].nil?
                        media.media_status = media_tag["StatusName"] unless media_tag["StatusName"].nil?
                        media.media_category = media_tag["CategoryName"] unless media_tag["CategoryName"].nil?
                        media.media_type = File.extname(media.image_file_name).strip.downcase[1..-1] unless media.image_file_name.nil?
                        media.forsale = media_tag["forSale"] unless media_tag["forSale"].nil?

#import sections, flags, keywords

                        media.pubdate = (media_tag["pubdate"].nil? ? Time.now : media_tag["pubdate"])
                        media.publish_status = (media_tag["isPublished"] == 'true' ? "Published" : "Attached")

                        media.update_attributes(uuid: s_to_uuid(media_tag["uuid"]), media_name: media_tag["title"])
                        #puts '   Image: #'+media.id.to_s + " - " + uuid_to_s(media.uuid) + " - " + media.media_name
                    end
                end

                story.save!
                story.index!

                # Display imported story record
                puts '   Story: #'+story.id.to_s + " - " + uuid_to_s(story.uuid) + " - " + story.hl1
                puts "      Errors: "+story.errors.full_messages.inspect if story.errors.present?
                unless story.story_images.nil?
                    story.story_images.each do |image|
                        puts '      Image: #'+image.id.to_s + " - " + image.media_name
                    end
                end
            
                # import author records
                authors = Array.wrap(item["authors"]["author"]) unless item["authors"].nil?
                unless authors.nil?
                    authors.each do |x|
#                       author = story.authors.find_or_create_by(text: x)
                    end
                end

                # import section records
                sections = Array.wrap(item["sections"]["section"]) unless item["sections"].nil?
                unless sections.nil?
                    sections.each do |x|
    #                    section = story.sections.find_or_create_by(text: x)
                    end
                end

                # import keyword records
                keywords = Array.wrap(item["keywords"]["keyword"]) unless item["keywords"].nil?
                unless keywords.nil?
                    keywords.each do |x|
                        keyword = story.keywords.find_or_create_by(text: x)
                    end
                end

                # import flag records
                flags = Array.wrap(item["flags"]["flag"]) unless item["flags"].nil?
                unless flags.nil?
                    flags.each do |x|
    #                    flag = story.flags.find_or_create_by(text: x)
                    end
                end
            end
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

        import_files
    end
end