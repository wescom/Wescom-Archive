# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130221202732) do

  create_table "correction_links", :force => true do |t|
    t.integer  "story_id"
    t.integer  "correction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords", :force => true do |t|
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords_stories", :id => false, :force => true do |t|
    t.integer "story_id"
    t.integer "keyword_id"
  end

  create_table "papers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publications", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "section_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "category"
  end

  create_table "site_settings", :force => true do |t|
    t.text     "site_announcement"
    t.boolean  "show_site_announcement"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "stories", :force => true do |t|
    t.string   "hl1"
    t.date     "pubdate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "page",             :limit => 50
    t.string   "byline"
    t.text     "copy"
    t.integer  "doc_id"
    t.string   "copyright_holder"
    t.string   "doc_name"
    t.integer  "publication_id"
    t.integer  "section_id"
    t.integer  "paper_id"
    t.string   "hl2"
    t.string   "tagline"
    t.text     "sidebar_body"
    t.string   "project_group"
    t.string   "frontend_db"
  end

  add_index "stories", ["project_group"], :name => "index_stories_on_project_group"
  add_index "stories", ["pubdate"], :name => "index_stories_on_pubdate"

  create_table "story_images", :force => true do |t|
    t.integer  "story_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "media_id"
    t.string   "media_name"
    t.integer  "media_height"
    t.integer  "media_width"
    t.string   "media_mime_type"
    t.string   "media_source"
    t.text     "media_printcaption"
    t.string   "media_printproducer"
    t.text     "media_originalcaption"
    t.string   "media_byline"
    t.string   "media_project_group"
    t.string   "media_notes"
    t.string   "media_status"
    t.string   "media_type"
    t.string   "publish_status"
  end

  add_index "story_images", ["story_id"], :name => "index_story_images_on_story_id"

  create_table "story_topics", :force => true do |t|
    t.integer  "story_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "identity"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

end
