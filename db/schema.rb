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

ActiveRecord::Schema.define(version: 20161010125329) do

  create_table "answers", force: true do |t|
    t.string   "tester_id"
    t.string   "questionnaire"
    t.string   "question"
    t.string   "device_id"
    t.string   "answer_label"
    t.string   "answer_value"
    t.string   "answer_time"
    t.string   "user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question"], name: "index_answers_on_question", using: :btree
  add_index "answers", ["questionnaire"], name: "index_answers_on_questionnaire", using: :btree
  add_index "answers", ["user"], name: "index_answers_on_user", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "order"
    t.integer  "questionnaire_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "image"
    t.integer  "audio"
  end

  add_index "categories", ["questionnaire_id"], name: "index_categories_on_questionnaire_id", using: :btree

  create_table "media_files", force: true do |t|
    t.string   "ref"
    t.string   "media_type"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "media_files", ["question_id"], name: "index_media_files_on_question_id", using: :btree

  create_table "questionnaires", force: true do |t|
    t.string   "name"
    t.boolean  "public"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "has_result_categories"
  end

  add_index "questionnaires", ["user_id"], name: "index_questionnaires_on_user_id", using: :btree

  create_table "questions", force: true do |t|
    t.string   "name"
    t.text     "text"
    t.text     "settings"
    t.integer  "response_id"
    t.boolean  "is_public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.integer  "order"
    t.integer  "question_image"
    t.integer  "question_audio"
    t.integer  "represent_category_id"
  end

  add_index "questions", ["category_id"], name: "index_questions_on_category_id", using: :btree

  create_table "response_option_items", force: true do |t|
    t.integer  "value"
    t.text     "label"
    t.text     "audio"
    t.integer  "response_option_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "response_option_items", ["response_option_id"], name: "index_response_option_items_on_response_option_id", using: :btree

  create_table "response_options", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "availability"
    t.integer  "question_id"
    t.integer  "questionnaire_id"
  end

  add_index "response_options", ["questionnaire_id"], name: "index_response_options_on_questionnaire_id", using: :btree

  create_table "result_categories", force: true do |t|
    t.string   "name"
    t.integer  "order"
    t.integer  "questionnaire_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "result_categories", ["questionnaire_id"], name: "index_result_categories_on_questionnaire_id", using: :btree

  create_table "rights", force: true do |t|
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "questionnaire_id"
    t.integer  "subject_id"
  end

  add_index "rights", ["questionnaire_id"], name: "index_rights_on_questionnaire_id", using: :btree
  add_index "rights", ["user_id"], name: "index_rights_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "create_user_permission"
    t.boolean  "create_questionnaire_permission"
  end

end
