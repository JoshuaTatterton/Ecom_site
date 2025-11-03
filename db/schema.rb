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

ActiveRecord::Schema[8.1].define(version: 2025_11_03_212937) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_settings", force: :cascade do |t|
    t.string "account_reference", null: false
    t.string "bundle_prefix"
    t.string "category_prefix"
    t.datetime "created_at", null: false
    t.string "product_prefix"
    t.datetime "updated_at", null: false
    t.index ["account_reference"], name: "unique_account_settings", unique: true
  end

  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "reference", null: false
    t.datetime "updated_at", null: false
    t.index ["reference"], name: "unique_accounts", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.string "account_reference", null: false
    t.datetime "created_at", null: false
    t.bigint "role_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["account_reference", "user_id"], name: "unique_user_account_memberships", unique: true
    t.index ["role_id"], name: "index_memberships_on_role_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "account_reference", null: false
    t.boolean "administrator", default: false, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.jsonb "permissions", default: [], null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "awaiting_authentication", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name"
    t.string "password_digest"
    t.string "recovery_password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "unique_users", unique: true
    t.check_constraint "awaiting_authentication = true OR name IS NOT NULL", name: "user_name_required"
    t.check_constraint "awaiting_authentication = true OR password_digest IS NOT NULL", name: "user_password_required"
  end
end
