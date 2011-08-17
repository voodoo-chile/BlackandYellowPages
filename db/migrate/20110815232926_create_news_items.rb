class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.integer :user_id
      t.string :title
      t.text :body
      t.boolean :featured
      t.timestamps
    end
  end

  def self.down
    drop_table :news_items
  end
end
