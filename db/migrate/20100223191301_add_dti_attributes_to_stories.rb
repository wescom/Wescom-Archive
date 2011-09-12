class AddDtiAttributesToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :doc_id, :integer
    add_column :stories, :copyright_holder, :string
    add_column :stories, :doc_name, :string
    add_column :stories, :publication_id, :integer
    add_column :stories, :section_id, :integer
    add_column :stories, :paper_id, :integer
    add_column :stories, :hl2, :string
    add_column :stories, :tagline, :string
    add_column :stories, :correction_id, :integer
    rename_column :stories, :headline, :hl1
  end

  def self.down
    rename_column :stories, :hl1, :headline
    remove_column :stories, :correction_id
    remove_column :stories, :tagline
    remove_column :stories, :hl2
    remove_column :stories, :paper_id
    remove_column :stories, :section_id
    remove_column :stories, :publication_id
    remove_column :stories, :doc_name
    remove_column :stories, :copyright_holder
    remove_column :stories, :doc_id
  end
end
