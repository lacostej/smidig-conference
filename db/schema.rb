# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090510152948) do

  create_table "comments", :force => true do |t|
    t.integer  "talk_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.boolean  "is_displayed"
    t.boolean  "is_a_review"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_deliveries", :force => true do |t|
    t.integer  "message_id"
    t.integer  "registration_id"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.boolean  "is_published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "periods", :force => true do |t|
    t.integer  "time_id"
    t.integer  "scene_id"
    t.integer  "topic_id"
    t.integer  "topic_offset"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", :force => true do |t|
    t.integer  "user_id"
    t.text     "comments"
    t.decimal  "price"
    t.date     "invoiced_at"
    t.date     "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "talks", :force => true do |t|
    t.integer  "speaker_id"
    t.integer  "topic_id"
    t.string   "title"
    t.text     "description"
    t.string   "slideshare_url"
    t.boolean  "presenting_naked"
    t.string   "video_url"
    t.integer  "position"
    t.boolean  "submitted"
    t.integer  "red_votes"
    t.integer  "yellow_votes"
    t.integer  "green_votes"
    t.string   "audience_level"
    t.integer  "votes_count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "openid_identifier"
    t.string   "email",                             :null => false
    t.string   "crypted_password",                  :null => false
    t.string   "password_salt",                     :null => false
    t.string   "persistence_token",                 :null => false
    t.string   "name"
    t.string   "company"
    t.string   "phone_number"
    t.text     "billing_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "login_count",        :default => 0, :null => false
    t.integer  "failed_login_count", :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
  end

  add_index "users", ["openid_identifier"], :name => "index_users_on_openid_identifier"

  create_table "votes", :force => true do |t|
    t.integer  "talk_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
