# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110825000121) do

  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.string   "phone"
    t.string   "skype"
    t.string   "aol"
    t.string   "icq"
    t.string   "yim"
    t.text     "public_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["user_id"], :name => "index_contacts_on_user_id"

  create_table "news_items", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.boolean  "featured"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "news_items", ["slug"], :name => "index_news_items_on_slug", :unique => true

  create_table "specialties", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "url"
    t.string   "phone"
    t.string   "email"
    t.string   "line1",       :limit => 50
    t.string   "line2",       :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "street"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.string   "postal_code"
  end

  create_table "sponsor_keys", :force => true do |t|
    t.integer  "sponsor_id"
    t.integer  "user_id"
    t.string   "key"
    t.boolean  "used"
    t.date     "expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsorship_offers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "sponsor_id"
    t.date     "expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     :default => "pending"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "trust_links", :force => true do |t|
    t.integer  "user_id"
    t.integer  "trustee"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.integer  "roles_mask"
    t.integer  "sponsor_id"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "last_login_at"
    t.string   "perishable_token",  :default => "",    :null => false
    t.boolean  "active",            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "current_login_at"
    t.string   "slug"
  end

  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true
  add_index "users", ["sponsor_id"], :name => "index_users_on_sponsor_id"

end
