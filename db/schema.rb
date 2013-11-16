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

ActiveRecord::Schema.define(version: 20131116074514) do

  create_table "alternatives", force: true do |t|
    t.string   "name"
    t.text     "desc"
    t.string   "tw_hash"
    t.decimal  "value"
    t.integer  "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "reject",                  default: false
    t.integer  "last_tweet_id", limit: 8
  end

  add_index "alternatives", ["problem_id"], name: "index_alternatives_on_problem_id"

  create_table "criteria", force: true do |t|
    t.string   "name"
    t.text     "desc"
    t.string   "tw_hash"
    t.integer  "problem_id"
    t.text     "alternatives_matrix"
    t.text     "alternatives_value"
    t.decimal  "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "reject",                        default: false
    t.integer  "last_tweet_id",       limit: 8
  end

  add_index "criteria", ["problem_id"], name: "index_criteria_on_problem_id"

  create_table "installs", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "installs", ["email"], name: "index_installs_on_email", unique: true
  add_index "installs", ["reset_password_token"], name: "index_installs_on_reset_password_token", unique: true

  create_table "problems", force: true do |t|
    t.string   "name"
    t.text     "desc"
    t.string   "tw_hash"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_tweet_id", limit: 8
  end

  create_table "tweets", force: true do |t|
    t.integer  "problem_id"
    t.integer  "tweet_id",      limit: 8
    t.string   "tw_hash"
    t.integer  "retweet_count"
    t.string   "text"
    t.float    "polarity"
    t.datetime "created_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tweets", ["problem_id"], name: "index_tweets_on_problem_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "twitter_nickname",       default: "", null: false
    t.string   "twitter_id",             default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "users_problems", force: true do |t|
    t.integer "user_id"
    t.integer "problem_id"
    t.boolean "owner"
  end

  add_index "users_problems", ["problem_id"], name: "index_users_problems_on_problem_id"
  add_index "users_problems", ["user_id"], name: "index_users_problems_on_user_id"

end
