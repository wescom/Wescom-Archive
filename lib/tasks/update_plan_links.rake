namespace :wescom do

  desc "Update PDF links to Plans"
  task :update_pdf_plans  => :environment do
    def update_pdf_links
      pdf_images = PdfImage.where('plan_id is null')
      pdf_images.each do |pdf|
        puts "PDF Record =  "+"#"+pdf.id.to_s + " - " + pdf.image_file_name unless pdf.image_file_name.nil?
        pdf.plan = Plan.find_or_create_by_import_pub_name_and_import_section_name(pdf.publication,pdf.section_name)
        #puts "    "+pdf.plan.id.to_s
        #puts "    "+pdf.plan.import_pub_name
        #puts "    "+pdf.plan.import_section_name
        pdf.save
      end
    end

    update_pdf_links

  end

  desc "Update Story links to Plans"
  task :update_story_plans  => :environment do
    def update_pdf_links
      stories = Story.where('plan_id is null and frontend_db = "DTI"')
      stories.each do |story|
        story_pub = story.publication.nil? ? "" : story.publication.name
        story_section = story.section.nil? ? "" : story.section.name
        puts "Story Record =  "+"#"+story.id.to_s + ", " + story_pub + ", " + story_section
        story.plan = Plan.find_or_create_by_import_pub_name_and_import_section_name(story_pub,story_section)
        puts "  Plan #"+story.plan.id.to_s+", "+story.plan.import_pub_name+", "+story.plan.import_section_name
        story.save
      end
    end

    update_pdf_links

  end
end