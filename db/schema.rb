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

ActiveRecord::Schema.define(:version => 20130519061622) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "category_entry_mappings", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "clients", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "client_id",  :null => false
    t.string   "channel",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "item_id",                       :null => false
    t.text     "body",                          :null => false
    t.boolean  "edited",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "html"
  end

  add_index "comments", ["id"], :name => "comments_id"
  add_index "comments", ["item_id"], :name => "comments_item_id"

  create_table "entries", :force => true do |t|
    t.string   "guid",              :limit => 4096
    t.integer  "source_id"
    t.string   "title",             :limit => 4096
    t.string   "url",               :limit => 4096,                     :null => false
    t.string   "author",            :limit => 4096
    t.string   "summary",           :limit => 4096
    t.text     "content"
    t.datetime "published_at"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.boolean  "processed",                         :default => false
    t.boolean  "delivered",                         :default => false
    t.boolean  "content_inlined",                   :default => false
    t.boolean  "content_embedded",                  :default => false
    t.boolean  "content_sanitized",                 :default => false
    t.integer  "entry_guid_id"
    t.string   "source_type",                       :default => "Feed"
  end

  add_index "entries", ["guid"], :name => "index_entries_on_guid"
  add_index "entries", ["id"], :name => "entries_id"
  add_index "entries", ["source_id", "guid"], :name => "entries_feed_id_guid"
  add_index "entries", ["source_id"], :name => "index_entries_on_feed_id"
  add_index "entries", ["url"], :name => "index_entries_on_url"

  create_table "entry_guids", :force => true do |t|
    t.integer "source_id"
    t.string  "guid",        :limit => 4096
    t.string  "source_type",                 :default => "Feed"
  end

  add_index "entry_guids", ["guid"], :name => "index_entry_guids_on_guid"
  add_index "entry_guids", ["source_id", "guid"], :name => "feed_id_guid", :unique => true
  add_index "entry_guids", ["source_id"], :name => "index_entry_guids_on_feed_id"
  add_index "entry_guids", ["source_id"], :name => "new_entry_guid_feed_id_index", :order => {"source_id"=>:desc}

  create_table "facebook_contacts", :force => true do |t|
    t.integer  "left_user_id"
    t.integer  "right_user_id"
    t.text     "names"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "feed_icons", :force => true do |t|
    t.integer  "feed_id"
    t.string   "uri",        :limit => 4096
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "feed_icon",  :limit => 4096
  end

  add_index "feed_icons", ["feed_id"], :name => "index_feed_icons_on_feed_id"

  create_table "feeds", :force => true do |t|
    t.string   "name",                                                     :null => false
    t.integer  "user_id"
    t.string   "feed_url",              :limit => 4096
    t.string   "site_url",              :limit => 4096
    t.text     "description"
    t.boolean  "suggested",                             :default => false
    t.boolean  "private",                               :default => false
    t.datetime "fetched_at"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.boolean  "fetchable",                             :default => true
    t.text     "hub"
    t.text     "topic"
    t.string   "token"
    t.integer  "timeouts",                              :default => 0
    t.integer  "parse_errors",                          :default => 0
    t.boolean  "push_subscribed",                       :default => false
    t.string   "secret_token"
    t.string   "etag"
    t.integer  "average_posts_per_day"
    t.integer  "subscription_count"
    t.integer  "feed_errors",                           :default => 0
    t.string   "current_feed_url",      :limit => 4096
    t.integer  "connection_errors",                     :default => 0
    t.integer  "fetch_count",                           :default => 0
    t.string   "document",              :limit => 4096
    t.text     "document_text"
    t.datetime "last_fetched_at"
  end

  add_index "feeds", ["feed_url"], :name => "index_feeds_on_feed_url"
  add_index "feeds", ["id"], :name => "feeds_id"

  create_table "fetch_errors", :force => true do |t|
    t.integer  "feed_id"
    t.string   "http_status"
    t.string   "message"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "follows", :force => true do |t|
    t.integer  "followable_id",                      :null => false
    t.string   "followable_type",                    :null => false
    t.integer  "follower_id",                        :null => false
    t.string   "follower_type",                      :null => false
    t.boolean  "blocked",         :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "ignored",         :default => false
  end

  add_index "follows", ["followable_id", "followable_type"], :name => "fk_followables"
  add_index "follows", ["follower_id", "follower_type"], :name => "fk_follows"

  create_table "groups", :force => true do |t|
    t.string   "label"
    t.string   "key"
    t.integer  "user_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "open",       :default => true
    t.integer  "weight",     :default => 0
    t.string   "item_view"
  end

  add_index "groups", ["user_id", "key"], :name => "user_key", :unique => true

  create_table "items", :force => true do |t|
    t.integer  "user_id",                             :null => false
    t.integer  "entry_id"
    t.integer  "subscription_id"
    t.boolean  "unread",           :default => true
    t.boolean  "starred",          :default => false
    t.boolean  "shared",           :default => false
    t.boolean  "browsed",          :default => false
    t.boolean  "liked",            :default => false
    t.integer  "parent_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "share_delivered",  :default => false
    t.integer  "from_id"
    t.boolean  "has_new_comments"
    t.boolean  "commented",        :default => false
    t.boolean  "sent_to_facebook"
    t.string   "facebook_id"
    t.boolean  "sent_to_twitter"
    t.string   "twitter_id"
  end

  add_index "items", ["commented"], :name => "index_items_on_commented"
  add_index "items", ["entry_id"], :name => "index_items_on_entry_id"
  add_index "items", ["has_new_comments"], :name => "index_items_on_has_new_comments"
  add_index "items", ["id"], :name => "index_items_on_id"
  add_index "items", ["shared"], :name => "index_items_on_shared"
  add_index "items", ["starred"], :name => "index_items_on_starred"
  add_index "items", ["subscription_id"], :name => "index_items_on_subscription_id"
  add_index "items", ["unread"], :name => "index_items_on_unread"
  add_index "items", ["user_id", "entry_id", "from_id"], :name => "item_user_from_entry", :unique => true
  add_index "items", ["user_id"], :name => "index_items_on_user_id"

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "name"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.integer  "weight",                          :default => 0
    t.integer  "unread_count"
    t.integer  "starred_count"
    t.integer  "shared_count"
    t.integer  "all_count"
    t.integer  "commented_count"
    t.boolean  "deleted",                         :default => false
    t.string   "item_view"
    t.boolean  "favorite",                        :default => false
    t.string   "sort"
    t.string   "site_url",        :limit => 4096
    t.string   "icon_path",       :limit => 4096
    t.integer  "source_id"
    t.string   "source_type"
  end

  add_index "subscriptions", ["id"], :name => "subscriptions_id"

  create_table "users", :force => true do |t|
    t.string   "email",                          :default => "",    :null => false
    t.string   "name",                                              :null => false
    t.string   "encrypted_password",             :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                  :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.datetime "last_seen_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.boolean  "anonymous",                      :default => false
    t.string   "websocket_token",                                   :null => false
    t.string   "public_token",                                      :null => false
    t.integer  "shared_feed_id"
    t.integer  "starred_feed_id"
    t.string   "singly_account_id"
    t.string   "singly_access_token"
    t.boolean  "share_to_twitter"
    t.boolean  "share_to_facebook"
    t.boolean  "registration_complete",          :default => false
    t.integer  "subscription_count"
    t.integer  "unread_count"
    t.integer  "starred_count"
    t.integer  "shared_count"
    t.integer  "all_count"
    t.text     "stripe_data"
    t.boolean  "premium_account",                :default => false
    t.string   "stripe_customer_id"
    t.boolean  "premium_account_cancel_pending", :default => false
    t.integer  "has_new_comments_count"
    t.integer  "commented_count"
    t.boolean  "free_account",                   :default => false
    t.boolean  "agree_to_terms",                 :default => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
