class CreateSponsorKeys < ActiveRecord::Migration
  def self.up
    create_table :sponsor_keys do |t|
      t.integer :sponsor_id
      t.integer :user_id
      t.string :key
      t.boolean :used
      t.date :expiration

      t.timestamps
    end
  end

  def self.down
    drop_table :sponsor_keys
  end
end
