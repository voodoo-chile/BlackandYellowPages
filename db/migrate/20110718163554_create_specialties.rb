class CreateSpecialties < ActiveRecord::Migration
  def self.up
    create_table :specialties do |t|
      t.integer :user_id
      t.string :name
      t.string :url
      t.string :phone
      t.string :email
      t.string :line1, :limit => 50
      t.string :line2, :limit => 50
      t.timestamps
    end
  end

  def self.down
    drop_table :specialties
  end
end
