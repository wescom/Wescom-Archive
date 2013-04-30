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
  validates :page, :presence => true, :numericality => true, :on => :update

  searchable :auto_index => true, :auto_remove => true do
    # Search fields
    text :hl1, :default_boost => 2.0, :stored => true
    text :hl2, :stored => true
    text :page
    text :byline, :default_boost => 3.0, :stored => true
    text :tagline
    text :copy, :publish_year
    text :sidebar_body
    text :project_group

    # Sort fields - must use 'string' instead of 'text'
    integer :story_location_id do
      plan.location_id if plan.present?
    end
    integer :story_pub_type_id do
      plan.publication_type_id if plan.present?
    end
    string :story_publication_name do
      publication_name
    end
    string :story_section_name do
      section_name
    end
    integer :page

    time :pubdate

  end

  def publish_year
    if !pubdate.nil?
      pubdate.strftime("%Y")
    end
  end
  
  def self.order_by_pub_section_page
    includes(:plan).order('plans.pub_name').order('plans.section_name').order('page')
  end
  
  def section_name
    self.plan.section_name if self.plan.present?
  end
  
  def publication_name
    self.plan.pub_name if self.plan.present?
  end
  
  def self.has_pubdate_in_range(date_from, date_to)  
    return scoped unless date_from.present? AND date_to.present?
    where("pubdate >= ? AND pubdate <= ?", date_from, date_to)  
  end

end
