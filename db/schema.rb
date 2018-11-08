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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_02_09_224933) do

  create_table "correction_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "story_id"
    t.integer "correction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords_stories", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "story_id"
    t.integer "keyword_id"
    t.index ["keyword_id"], name: "index_keywords_stories_on_keyword_id"
    t.index ["story_id"], name: "index_keywords_stories_on_story_id"
  end

  create_table "locations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_locations_on_name"
  end

  create_table "logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "story_id"
    t.integer "story_image_id"
    t.integer "plan_id"
    t.integer "pdf_image_id"
    t.string "log_action"
    t.string "log_detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "papers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pdf_images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.date "pubdate"
    t.string "publication"
    t.string "section_letter"
    t.string "section_name"
    t.integer "page"
    t.integer "plan_id"
    t.text "pdf_text"
    t.index ["page"], name: "index_pdf_images_on_page"
    t.index ["plan_id"], name: "index_pdf_images_on_plan_id"
    t.index ["pubdate", "publication", "page"], name: "date_pub_page"
    t.index ["pubdate", "publication", "section_letter", "page"], name: "date_pub_letter_page"
    t.index ["pubdate", "publication", "section_letter", "section_name", "page"], name: "date_pub_letter_name_page"
    t.index ["pubdate", "section_letter", "page"], name: "date_letter_page"
    t.index ["pubdate"], name: "index_pdf_images_on_pubdate"
    t.index ["publication"], name: "index_pdf_images_on_publication"
    t.index ["section_letter", "page"], name: "letter_page"
    t.index ["section_letter"], name: "index_pdf_images_on_section_letter"
  end

  create_table "plans", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "pub_name"
    t.string "section_name"
    t.string "import_pub_name"
    t.string "import_section_name"
    t.string "publication_type_id"
    t.string "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "import_section_letter"
    t.index ["location_id"], name: "index_plans_on_location_id"
    t.index ["pub_name"], name: "index_plans_on_pub_name"
    t.index ["publication_type_id"], name: "index_plans_on_publication_type_id"
    t.index ["section_name"], name: "index_plans_on_section_name"
  end

  create_table "publication_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "location_id"
    t.integer "publication_type_id"
  end

  create_table "section_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "section_category_id"
  end

  create_table "site_settings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "site_announcement"
    t.boolean "show_site_announcement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "show_delete_button"
  end

  create_table "stories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "hl1"
    t.date "pubdate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "page", limit: 50
    t.string "byline"
    t.text "copy"
    t.integer "doc_id"
    t.string "copyright_holder"
    t.string "doc_name"
    t.integer "publication_id"
    t.integer "section_id"
    t.integer "paper_id"
    t.string "hl2"
    t.string "tagline"
    t.text "sidebar_body"
    t.string "project_group"
    t.string "frontend_db"
    t.integer "plan_id"
    t.string "pageset_letter"
    t.string "author"
    t.string "origin"
    t.string "deskname"
    t.string "categoryname"
    t.string "subcategoryname"
    t.text "memo"
    t.text "notes"
    t.datetime "expiredate"
    t.datetime "web_published_at"
    t.string "related_stories"
    t.string "web_hl1"
    t.string "web_hl2"
    t.text "web_text"
    t.text "toolbox2"
    t.text "toolbox3"
    t.text "toolbox4"
    t.text "toolbox5"
    t.text "web_summary"
    t.string "kicker"
    t.string "videourl"
    t.string "alternateurl"
    t.string "map"
    t.text "caption"
    t.text "htmltext"
    t.boolean "approved"
    t.string "web_pubnum"
    t.index ["categoryname"], name: "index_stories_on_categoryname"
    t.index ["doc_id"], name: "index_stories_on_doc_id"
    t.index ["plan_id"], name: "index_stories_on_plan_id"
    t.index ["project_group"], name: "index_stories_on_project_group"
    t.index ["pubdate"], name: "index_stories_on_pubdate"
    t.index ["subcategoryname"], name: "index_stories_on_subcategoryname"
    t.index ["web_pubnum"], name: "index_stories_on_web_pubnum"
  end

  create_table "story_images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "story_id"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "media_id"
    t.string "media_name"
    t.integer "media_height"
    t.integer "media_width"
    t.string "media_mime_type"
    t.string "media_source"
    t.text "media_printcaption"
    t.string "media_printproducer"
    t.text "media_originalcaption"
    t.string "media_byline"
    t.string "media_project_group"
    t.string "media_notes"
    t.string "media_status"
    t.string "media_type"
    t.string "publish_status"
    t.text "media_webcaption"
    t.string "byline_title"
    t.string "deskname"
    t.string "priority"
    t.datetime "created_date"
    t.datetime "last_refreshed_time"
    t.datetime "expire_date"
    t.string "media_category"
    t.index ["image_updated_at"], name: "index_story_images_on_image_updated_at"
    t.index ["media_id"], name: "index_story_images_on_media_id"
    t.index ["story_id"], name: "index_story_images_on_story_id"
  end

  create_table "story_topics", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "story_id"
    t.integer "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "identity"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "role", default: "View"
    t.integer "search_count", default: 0
    t.string "login"
    t.string "name"
    t.text "group_strings"
    t.string "ou_strings"
    t.integer "default_location_id"
    t.integer "default_publication_type_id"
    t.string "default_publication"
    t.string "default_section_name"
  end

end
