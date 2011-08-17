class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :email
      t.integer :roles_mask
      t.integer :sponsor_id
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.datetime :last_login_at
      t.string :perishable_token, :default => "", :null => false
      t.boolean :active, :default => false, :null => false
      t.timestamps
    end
    add_index(:users, :sponsor_id)
  end

  def self.down
    drop_table :users
  end
end
