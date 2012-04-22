class Story < ActiveRecord::Base
  belongs_to :publication
  belongs_to :section
  belongs_to :paper

  has_many :story_keywords
  has_many :story_topics
  has_many :keywords, :through => :story_keywords
  has_many :topics, :through => :story_topics
  has_many :correction_links
  has_many :corrections, :through => :correction_links
  has_many :inverse_correction_links, :class_name => 'CorrectionLink', :foreign_key => "correction_id"
  has_many :corrected_stories, :through => :inverse_correction_links, :source => :story

  searchable do
    text :hl1, :default_boost => 2.0, :stored => true
    text :hl2, :stored => true
    text :page
    text :byline, :default_boost => 3.0, :stored => true
    text :tagline
    text :copy

    integer :doc_id
    integer :publication_id, :references => Publication
    integer :section_id, :references => Section
    integer :paper_id, :references => Paper

    text :keywords do
      keywords.map {|kw| kw.text}
    end

    text :topics do
      topics.map {|tp| tp.text}
    end
  end

end
