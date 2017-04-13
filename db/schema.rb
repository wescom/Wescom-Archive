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

ActiveRecord::Schema.define(:version => 20170312060817) do

  create_table "ar_internal_metadata", :primary_key => "key", :force => true do |t|
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cart_items", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "quantity"
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "price_cents",    :default => 0,     :null => false
    t.string   "price_currency", :default => "USD", :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "carts", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "correction_links", :force => true do |t|
    t.integer  "story_id"
    t.integer  "correction_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "default_settings", :force => true do |t|
    t.decimal  "image_price",             :precision => 12, :scale => 3
    t.decimal  "pdf_price",               :precision => 12, :scale => 3
    t.text     "image_use_license"
    t.string   "confirmation_from_email"
    t.text     "home_welcome_text"
    t.string   "home_image_cat1_name"
    t.string   "home_image_cat1"
    t.string   "home_image_cat2_name"
    t.string   "home_image_cat2"
    t.string   "home_image_cat3_name"
    t.string   "home_image_cat3"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  create_table "keywords", :force => true do |t|
    t.string   "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "keywords_stories", :id => false, :force => true do |t|
    t.integer "story_id"
    t.integer "keyword_id"
  end

  add_index "keywords_stories", ["keyword_id"], :name => "index_keywords_stories_on_keyword_id"
  add_index "keywords_stories", ["story_id"], :name => "index_keywords_stories_on_story_id"

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "locations", ["name"], :name => "index_locations_on_name"

  create_table "logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "story_id"
    t.integer  "story_image_id"
    t.integer  "plan_id"
    t.integer  "pdf_image_id"
    t.string   "log_action"
    t.string   "log_detail"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.integer  "price_cents",    :default => 0,     :null => false
    t.string   "price_currency", :default => "USD", :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "orders", :force => true do |t|
    t.string   "obscure_uniq_identifier"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "last4"
    t.decimal  "amount",                  :precision => 12, :scale => 3
    t.boolean  "success"
    t.string   "authorization_code"
    t.string   "email"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  create_table "papers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pdf_images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.date     "pubdate"
    t.string   "publication"
    t.string   "section_letter"
    t.string   "section_name"
    t.integer  "page"
    t.integer  "plan_id"
    t.text     "pdf_text"
  end

  add_index "pdf_images", ["page"], :name => "index_pdf_images_on_page"
  add_index "pdf_images", ["plan_id"], :name => "index_pdf_images_on_plan_id"
  add_index "pdf_images", ["pubdate", "publication", "page"], :name => "date_pub_page"
  add_index "pdf_images", ["pubdate", "publication", "section_letter", "page"], :name => "date_pub_letter_page"
  add_index "pdf_images", ["pubdate", "publication", "section_letter", "section_name", "page"], :name => "date_pub_letter_name_page"
  add_index "pdf_images", ["pubdate"], :name => "index_pdf_images_on_pubdate"
  add_index "pdf_images", ["publication"], :name => "index_pdf_images_on_publication"
  add_index "pdf_images", ["section_letter"], :name => "index_pdf_images_on_section_letter"

  create_table "plans", :force => true do |t|
    t.string   "pub_name"
    t.string   "section_name"
    t.string   "import_pub_name"
    t.string   "import_section_name"
    t.string   "publication_type_id"
    t.string   "location_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "import_section_letter"
  end

  add_index "plans", ["location_id"], :name => "index_plans_on_location_id"
  add_index "plans", ["pub_name"], :name => "index_plans_on_pub_name"
  add_index "plans", ["publication_type_id"], :name => "index_plans_on_publication_type_id"
  add_index "plans", ["section_name"], :name => "index_plans_on_section_name"

  create_table "publication_types", :force => true do |t|
    t.string   "name"
    t.integer  "sort_order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "publications", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "location_id"
    t.integer  "publication_type_id"
  end

  create_table "section_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "section_category_id"
  end

  create_table "site_settings", :force => true do |t|
    t.text     "site_announcement"
    t.boolean  "show_site_announcement"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.boolean  "show_delete_button"
  end

  create_table "stories", :force => true do |t|
    t.string   "hl1"
    t.date     "pubdate"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
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
    t.integer  "plan_id"
    t.string   "pageset_letter"
    t.string   "author"
    t.string   "origin"
    t.string   "deskname"
    t.string   "categoryname"
    t.string   "subcategoryname"
    t.text     "memo"
    t.text     "notes"
    t.datetime "expiredate"
    t.datetime "web_published_at"
    t.string   "related_stories"
    t.string   "web_hl1"
    t.string   "web_hl2"
    t.text     "web_text"
    t.text     "toolbox2"
    t.text     "toolbox3"
    t.text     "toolbox4"
    t.text     "toolbox5"
    t.text     "web_summary"
    t.string   "kicker"
    t.string   "videourl"
    t.string   "alternateurl"
    t.string   "map"
    t.text     "caption"
    t.text     "htmltext"
    t.boolean  "approved"
    t.string   "web_pubnum"
  end

  add_index "stories", ["plan_id"], :name => "index_stories_on_plan_id"
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
    t.text     "media_webcaption"
    t.string   "byline_title"
    t.string   "deskname"
    t.string   "priority"
    t.datetime "created_date"
    t.datetime "last_refreshed_time"
    t.datetime "expire_date"
  end

  add_index "story_images", ["image_updated_at"], :name => "index_story_images_on_image_updated_at"
  add_index "story_images", ["story_id"], :name => "index_story_images_on_story_id"

  create_table "story_topics", :force => true do |t|
    t.integer  "story_id"
    t.integer  "topic_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "topics", :force => true do |t|
    t.string   "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "identity"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "role",                        :default => "View"
    t.integer  "search_count",                :default => 0
    t.string   "login"
    t.string   "name"
    t.text     "group_strings"
    t.string   "ou_strings"
    t.integer  "default_location_id"
    t.integer  "default_publication_type_id"
    t.string   "default_publication"
    t.string   "default_section_name"
  end

end
