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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121028063506) do

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.string   "start_url"
    t.string   "icon_url"
    t.string   "website_url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authorizations", :force => true do |t|
    t.string   "token",      :null => false
    t.text     "scope",      :null => false
    t.string   "origin",     :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["token"], :name => "index_authorizations_on_token"

  create_table "nodes", :force => true do |t|
    t.string   "path",                            :null => false
    t.text     "data"
    t.boolean  "directory"
    t.datetime "updated_at",                      :null => false
    t.string   "content_type",                    :null => false
    t.integer  "user_id",                         :null => false
    t.binary   "binary_data"
    t.boolean  "binary",       :default => false
  end

  add_index "nodes", ["path"], :name => "index_nodes_on_path"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

end
