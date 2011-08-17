class AddStatusToSponsorshipoffers < ActiveRecord::Migration
  def self.up
    add_column :sponsorship_offers, :status, :string, :default => "pending"
  end

  def self.down
    remove_column :sponsorship_offers, :status
  end
end
