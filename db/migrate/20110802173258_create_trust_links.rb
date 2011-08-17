class CreateTrustLinks < ActiveRecord::Migration
  def self.up
    create_table :trust_links do |t|
      t.integer :user_id
      t.integer :trustee

      t.timestamps
    end
  end

  def self.down
    drop_table :trust_links
  end
end
