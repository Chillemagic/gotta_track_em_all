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

ActiveRecord::Schema[8.0].define(version: 2025_10_18_051257) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cards", force: :cascade do |t|
    t.integer "card_api_id"
    t.string "name"
    t.integer "card_number"
    t.string "pokemon_set"
    t.date "release_date"
    t.string "artist"
    t.string "rarity"
    t.string "image_url"
    t.string "pokemon_types"
    t.string "finish_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "set_name"
  end

  create_table "collection_cards", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.bigint "card_id", null: false
    t.decimal "purchase_price"
    t.string "condition"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_collection_cards_on_card_id"
    t.index ["collection_id"], name: "index_collection_cards_on_collection_id"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "price_histories", force: :cascade do |t|
    t.bigint "cards_id", null: false
    t.decimal "price"
    t.string "source"
    t.date "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cards_id"], name: "index_price_histories_on_cards_id"
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
    t.string "trainer_type"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "collection_cards", "cards"
  add_foreign_key "collection_cards", "collections"
  add_foreign_key "collections", "users"
  add_foreign_key "price_histories", "cards", column: "cards_id"
end
