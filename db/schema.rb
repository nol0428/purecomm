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

ActiveRecord::Schema[7.1].define(version: 2025_08_27_131332) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", force: :cascade do |t|
    t.string "model_id"
    t.bigint "partnership_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partnership_id"], name: "index_chats_on_partnership_id"
  end

  create_table "checkins", force: :cascade do |t|
    t.string "mood"
    t.string "my_day"
    t.boolean "discuss", default: false
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
    t.bigint "user_id"
    t.bigint "partnership_id", null: false
    t.text "content"
    t.string "role", default: "user", null: false
    t.string "place_type"
    t.bigint "place_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kind"
    t.string "mood"
    t.string "day"
    t.string "wants_to_talk"
    t.string "love_language"
    t.string "temperament"
    t.text "note"
    t.text "advice"
    t.integer "author_kind"
    t.bigint "chat_id"
    t.string "model_id"
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
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

  create_table "tool_calls", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.string "name"
    t.jsonb "arguments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_tool_call_id"
    t.bigint "result_id"
    t.index ["message_id"], name: "index_tool_calls_on_message_id"
    t.index ["parent_tool_call_id"], name: "index_tool_calls_on_parent_tool_call_id"
    t.index ["result_id"], name: "index_tool_calls_on_result_id"
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
    t.string "personality"
    t.string "love_language"
    t.string "pronouns"
    t.string "hobbies"
    t.date "birthday"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chats", "partnerships"
  add_foreign_key "checkins", "partnerships"
  add_foreign_key "checkins", "users"
  add_foreign_key "grievances", "partnerships"
  add_foreign_key "grievances", "users"
  add_foreign_key "messages", "partnerships"
  add_foreign_key "messages", "users"
  add_foreign_key "partnerships", "users", column: "user_one_id"
  add_foreign_key "partnerships", "users", column: "user_two_id"
  add_foreign_key "tool_calls", "messages"
  add_foreign_key "tool_calls", "messages", column: "result_id"
  add_foreign_key "tool_calls", "tool_calls", column: "parent_tool_call_id"
end
