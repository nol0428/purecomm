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

ActiveRecord::Schema[7.1].define(version: 2025_08_25_071521) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "checkins", force: :cascade do |t|
    t.string "mood"
    t.string "my_day"
    t.boolean "discuss"
    t.text "comment"
    t.bigint "partnership_id", null: false
    t.time "nudge"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partnership_id"], name: "index_checkins_on_partnership_id"
    t.index ["user_id"], name: "index_checkins_on_user_id"
  end

  create_table "grievances", force: :cascade do |t|
    t.string "topic"
    t.string "feeling"
    t.text "situation"
    t.integer "intensity_scale"
    t.time "timing"
    t.bigint "partnership_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partnership_id"], name: "index_grievances_on_partnership_id"
    t.index ["user_id"], name: "index_grievances_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "partnership_id", null: false
    t.text "content"
    t.string "role"
    t.string "place_type"
    t.bigint "place_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partnership_id"], name: "index_messages_on_partnership_id"
    t.index ["place_type", "place_id"], name: "index_messages_on_place"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "partnerships", force: :cascade do |t|
    t.bigint "user_one_id"
    t.bigint "user_two_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_one_id"], name: "index_partnerships_on_user_one_id"
    t.index ["user_two_id"], name: "index_partnerships_on_user_two_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.bigint "partnership_id"
    t.string "personality"
    t.string "love_language"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["partnership_id"], name: "index_users_on_partnership_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "checkins", "partnerships"
  add_foreign_key "checkins", "users"
  add_foreign_key "grievances", "partnerships"
  add_foreign_key "grievances", "users"
  add_foreign_key "messages", "partnerships"
  add_foreign_key "messages", "users"
  add_foreign_key "partnerships", "users", column: "user_one_id"
  add_foreign_key "partnerships", "users", column: "user_two_id"
  add_foreign_key "users", "partnerships"
end
