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

ActiveRecord::Schema.define(version: 20191006165200) do

  create_table "approvals", force: :cascade do |t|
    t.integer "user_id"
    t.date "kintai_req_on"
    t.string "approval_status"
    t.integer "target_person_id"
    t.datetime "approval_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "baseplaces", force: :cascade do |t|
    t.string "kyoten_name"
    t.string "kyoten_shurui"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "editaprvls", force: :cascade do |t|
    t.integer "user_id"
    t.date "change_kintai_req_on"
    t.datetime "change_started_at"
    t.datetime "change_finished_at"
    t.string "note"
    t.string "change_aprvl_status"
    t.integer "change_target_person_id"
    t.datetime "approval_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "change_first_started_at"
    t.index ["user_id"], name: "index_editaprvls_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "department"
    t.integer "employer_number"
    t.string "uid"
    t.datetime "basic_time", default: "2019-02-19 22:30:00"
    t.datetime "work_time", default: "2019-02-19 23:00:00"
    t.datetime "work_end_time", default: "2019-02-19 23:00:00"
    t.boolean "superior"
    t.boolean "admin"
    t.string "password_digest"
    t.string "remember_digest"
  end

  create_table "zangyoaprvls", force: :cascade do |t|
    t.integer "user_id"
    t.date "zangyo_aprvl_req_on"
    t.datetime "zangyo_finished_at"
    t.string "zangyo_note"
    t.string "zangyo_aprvl_status"
    t.integer "zangyo_target_person_id"
    t.datetime "approval_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "yuko_flag"
    t.index ["user_id"], name: "index_zangyoaprvls_on_user_id"
  end

end
