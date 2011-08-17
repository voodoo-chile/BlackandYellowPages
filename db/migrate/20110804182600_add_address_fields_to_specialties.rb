class AddAddressFieldsToSpecialties < ActiveRecord::Migration
  def self.up
    add_column :specialties, :street, :string
    add_column :specialties, :city, :string
    add_column :specialties, :region, :string
    add_column :specialties, :country, :string
    add_column :specialties, :postal_code, :string
  end

  def self.down
    remove_column :specialties, :postal_code
    remove_column :specialties, :country
    remove_column :specialties, :region
    remove_column :specialties, :city
    remove_column :specialties, :street
  end
end
