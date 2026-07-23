# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_24_155626) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "analytics", force: :cascade do |t|
    t.bigint "short_url_id", null: false
    t.string "ip_address", null: false
    t.text "user_agent", null: false
    t.string "city"
    t.string "country"
    t.datetime "visited_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["short_url_id", "visited_at"], name: "index_analytics_on_short_url_id_and_visited_at"
  end

  create_table "ip_locations", force: :cascade do |t|
    t.string "ip_address", null: false
    t.string "country", null: false
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_address"], name: "index_ip_locations_on_ip_address", unique: true
  end

  create_table "short_urls", force: :cascade do |t|
    t.text "original_url", null: false
    t.string "slug"
    t.integer "visits", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fingerprint", null: false
    t.index ["fingerprint"], name: "index_short_urls_on_fingerprint", unique: true
    t.index ["slug"], name: "index_short_urls_on_slug", unique: true
  end

  add_foreign_key "analytics", "short_urls"
end
