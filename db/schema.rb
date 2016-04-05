# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160329011855) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",          null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body_html"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "location"
    t.datetime "time"
    t.text     "description"
    t.integer  "owner_id"
    t.integer  "threshold"
    t.datetime "deadline"
    t.string   "hash_key"
    t.string   "status"
    t.integer  "maximum_attendance"
    t.datetime "comments_last_mailed"
    t.boolean  "report_sent",          default: false
    t.boolean  "open",                 default: false,              null: false
    t.text     "description_html"
    t.boolean  "is_tipped",            default: false,              null: false
    t.string   "timezone",             default: "America/New_York"
    t.string   "cover_photo_url"
  end

  create_table "rsvps", force: true do |t|
    t.integer  "event_id",                                null: false
    t.integer  "user_id",                                 null: false
    t.integer  "response"
    t.string   "hash_key"
    t.boolean  "emailed"
    t.boolean  "wants_comments_emails",   default: true
    t.integer  "attendance_report"
    t.datetime "reminded"
    t.boolean  "reminder_to_attend_sent", default: false
    t.boolean  "hidden",                  default: false
    t.text     "excuse"
    t.boolean  "viewed",                  default: false, null: false
  end

  add_index "rsvps", ["event_id"], name: "index_rsvps_on_event_id", using: :btree
  add_index "rsvps", ["user_id"], name: "index_rsvps_on_user_id", using: :btree

  create_table "unfriendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "unfriend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "administrator",          default: false
    t.boolean  "confirmed",              default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
