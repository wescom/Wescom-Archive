class Story < ActiveRecord::Base
  belongs_to :publication
  belongs_to :section
  belongs_to :paper
  belongs_to :plan

  has_and_belongs_to_many :keywords
  has_many :story_topics
  has_many :topics, :through => :story_topics
  has_many :correction_links
  has_many :corrections, :through => :correction_links
  has_many :inverse_correction_links, :class_name => 'CorrectionLink', :foreign_key => "correction_id"
  has_many :corrected_stories, :through => :inverse_correction_links, :source => :story
  has_many :story_images, :dependent => :destroy

  validates :pubdate, :presence => true, :on => :update
  validates :section_id, :presence => true, :on => :update
  validates :page, :presence => true, :numericality => true, :on => :update

  searchable :auto_index => true, :auto_remove => true do
    text :hl1, :default_boost => 2.0, :stored => true
    text :hl2, :stored => true
    text :page
    text :byline, :default_boost => 3.0, :stored => true
    text :tagline
    text :copy, :publish_year
    text :sidebar_body
    text :project_group

    integer :publication_id, :references => Publication
    integer :section_id, :references => Section
    string :story_publication_name do
      publication_name
    end
    string :story_section_name do
      section_name
    end
    integer :page

    time :pubdate
#    string :publish_year

    # keywords from DTI, mostly taxonomy
#    text :keywords do
#      keywords.map {|kw| kw.text}
#    end

  end

  def publish_year
    if !pubdate.nil?
      pubdate.strftime("%Y")
    end
  end
  
  def self.order_by_section_page
    includes(:section).order('sections.name').order('page')
  end
  
  def self.order_by_pub_section_page
    includes(:plan).order('plans.pub_name').order('plans.section_name').order('page')
  end
  
  def section_name
    self.section.name if self.section.present?
  end
  
  def publication_name
    self.publication.name if self.publication.present?
  end
  
  def self.has_pubdate_in_range(date_from, date_to)  
    return scoped unless date_from.present? AND date_to.present?
    where("pubdate >= ? AND pubdate <= ?", date_from, date_to)  
  end

  def self.has_section_id(id)
    return scoped unless id.present?
    where("section_id = ?", id) if id
  end

  def self.has_publication_id(id)
    return scoped unless id.present?
    where("publication_id = ?", id)
  end
end
