class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.integer :user_id
      t.string :phone
      t.string :skype
      t.string :aol
      t.string :icq
      t.string :yim
      t.text :public_key

      t.timestamps
    end
    add_index(:contacts, :user_id)
  end

  def self.down
    drop_table :contacts
  end
end
