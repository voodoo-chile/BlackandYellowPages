class AddSlugToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :slug, :string
    add_index :news_items, :slug, :unique => true
  end

  def self.down
    remove_column :news_items, :slug
  end
end
