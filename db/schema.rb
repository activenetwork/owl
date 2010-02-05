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

ActiveRecord::Schema.define(:version => 20100203235137) do

  create_table "alert_handlers", :force => true do |t|
    t.string   "name"
    t.string   "class_name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alert_handlers", ["id"], :name => "index_alert_handlers_on_id", :unique => true

  create_table "alerts", :force => true do |t|
    t.integer  "watch_id"
    t.integer  "alert_handler_id"
    t.string   "to"
    t.boolean  "is_outstanding",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alerts", ["alert_handler_id"], :name => "index_alerts_on_alert_handler_id"
  add_index "alerts", ["id"], :name => "index_alerts_on_id", :unique => true
  add_index "alerts", ["watch_id"], :name => "index_alerts_on_watch_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["locked_by"], :name => "index_delayed_jobs_on_locked_by"

  create_table "headers", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "response_codes", :force => true do |t|
    t.integer  "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "responses", :force => true do |t|
    t.integer  "time"
    t.integer  "status"
    t.string   "reason"
    t.integer  "watch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "responses", ["id"], :name => "id_idx", :unique => true
  add_index "responses", ["watch_id"], :name => "watch_idx"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["id"], :name => "sites_id_idx", :unique => true

  create_table "statuses", :force => true do |t|
    t.string "name"
    t.string "css"
  end

  add_index "statuses", ["id"], :name => "statuses_id_idx", :unique => true

  create_table "watches", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "last_response_time",    :default => 0
    t.integer  "warning_time"
    t.boolean  "active",                :default => true
    t.string   "content_match"
    t.integer  "response_code_id",      :default => 200
    t.integer  "status_id",             :default => 1
    t.integer  "site_id"
    t.datetime "last_status_change_at"
    t.string   "status_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_locked",             :default => false
  end

  add_index "watches", ["id"], :name => "watches_id_idx", :unique => true
  add_index "watches", ["site_id"], :name => "watches_site_id_idx"

end
