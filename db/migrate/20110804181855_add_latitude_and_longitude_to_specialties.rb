class AddLatitudeAndLongitudeToSpecialties < ActiveRecord::Migration
  def self.up
    add_column :specialties, :latitude, :float
    add_column :specialties, :longitude, :float
  end

  def self.down
    remove_column :specialties, :longitude
    remove_column :specialties, :latitude
  end
end
