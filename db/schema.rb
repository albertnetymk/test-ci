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

ActiveRecord::Schema.define(version: 20160617122412) do

  create_table "prs", force: :cascade do |t|
    t.integer  "pr_id"
    t.string   "owner_repo_name"
    t.string   "repo_name"
    t.string   "base_ssh_url"
    t.string   "base_branch"
    t.string   "sha"
    t.string   "ssh_url"
    t.string   "branch"
    t.text     "details"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "prs", ["pr_id"], name: "index_prs_on_pr_id", unique: true

end
