class CreateSponsorshipOffers < ActiveRecord::Migration
  def self.up
    create_table :sponsorship_offers do |t|
      t.integer :user_id
      t.integer :sponsor_id
      t.date :expiration

      t.timestamps
    end
  end

  def self.down
    drop_table :sponsorship_offers
  end
end
