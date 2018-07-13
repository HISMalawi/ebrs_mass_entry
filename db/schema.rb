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

ActiveRecord::Schema.define(version: 0) do

  create_table "location", primary_key: "location_id", force: :cascade do |t|
    t.string   "code",            limit: 45
    t.string   "name",            limit: 255, default: "",    null: false
    t.string   "description",     limit: 255
    t.string   "postal_code",     limit: 50
    t.string   "country",         limit: 50
    t.string   "latitude",        limit: 50
    t.string   "longitude",       limit: 50
    t.integer  "creator",         limit: 4,   default: 0,     null: false
    t.datetime "created_at",                                  null: false
    t.string   "county_district", limit: 255
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by",       limit: 4
    t.datetime "date_voided"
    t.string   "void_reason",     limit: 255
    t.integer  "parent_location", limit: 4
    t.integer  "changed_by",      limit: 4
    t.datetime "changed_at"
  end

  add_index "location", ["changed_by"], name: "location_changed_by", using: :btree
  add_index "location", ["creator"], name: "user_who_created_location", using: :btree
  add_index "location", ["name"], name: "name_of_location", using: :btree
  add_index "location", ["parent_location"], name: "parent_location", using: :btree
  add_index "location", ["voided"], name: "retired_status", using: :btree
  add_index "location", ["voided_by"], name: "user_who_retired_location", using: :btree

  create_table "location_tag", primary_key: "location_tag_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 255
    t.integer  "locked",      limit: 1,   default: 0, null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.integer  "voided_by",   limit: 4
    t.string   "void_reason", limit: 45
    t.datetime "date_voided"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "location_tag", ["location_tag_id"], name: "location_tag_map_id_UNIQUE", unique: true, using: :btree

  create_table "location_tag_map", id: false, force: :cascade do |t|
    t.integer "location_id",     limit: 4, null: false
    t.integer "location_tag_id", limit: 4, null: false
  end

  add_index "location_tag_map", ["location_id"], name: "fk_location_tag_map_1", using: :btree
  add_index "location_tag_map", ["location_tag_id"], name: "fk_location_tag_map_2_idx", using: :btree

  create_table "user_role", force: :cascade do |t|
    t.integer "user_id", limit: 4, null: false
    t.integer "role_id",       limit: 4, null: false
  end

  add_index "user_role", ["user_id"], name: "user_role_user_id_foreign", using: :btree
  add_index "user_role", ["role_id"], name: "user_role_role_id_foreign", using: :btree

  create_table "role", primary_key: "role_id", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "role", ["name"], name: "role_name_unique", unique: true, using: :btree

  create_table "user", primary_key: "user_id", force: :cascade do |t|
    t.string   "username",       limit: 50,              null: false
    t.string   "password",       limit: 255,             null: false
    t.string   "first_name",                    limit: 255
    t.string   "middle_name",                    limit: 255
    t.string   "last_name",                    limit: 255
    t.string   "gender",         limit: 255
    t.string   "designation",    limit: 255
    t.datetime "last_password_date"
    t.datetime "deleted_at"                            
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end
  
	create_table "person", primary_key: "person_id", force: :cascade do |t|
   
    t.string   "first_name",      					limit: 255,             null: false
    t.string   "middle_name",          			limit: 255
    t.string   "last_name",                 limit: 255,               null: false

    t.string   "gender",                    limit: 255
    t.string   "date_of_birth",             limit: 255
    t.string   "place_of_birth",         		limit: 255

    t.string   "district_of_birth",    			limit: 255
    t.string   "ta_of_birth",          			limit: 255
    t.string   "village_of_birth", 					limit: 255
		t.string   "parents_married",						limit: 255

		t.string   "mother_first_name",					limit: 255
		t.string   "mother_middle_name",				limit: 255
		t.string   "mother_last_name",					limit: 255
		t.string   "mother_nationality",				limit: 255
		t.string   "mother_id_number",					limit: 255

		t.string   "father_first_name",					limit: 255
		t.string   "father_middle_name",				limit: 255
		t.string   "father_last_name",					limit: 255
		t.string   "father_nationality",				limit: 255
		t.string   "father_id_number",					limit: 255

		t.string   "informant_first_name",			limit: 255
		t.string   "informant_middle_name",			limit: 255
		t.string   "informant_last_name",				limit: 255
		t.string   "informant_nationality",			limit: 255
		t.string   "informant_id_number",				limit: 255
		t.string   "informant_district",				limit: 255
		t.string   "informant_ta",							limit: 255
		t.string   "informant_village",					limit: 255

		t.string   "informant_address_line1",		limit: 255
		t.string   "informant_address_line2",		limit: 255
		t.string   "informant_address_line3",		limit: 255
		t.string   "informant_phone_number",		limit: 255

		t.string   "informant_relationship",		limit: 255
		t.string   "form_signed",								limit: 255
		t.string   "date_reported",							limit: 255

		t.string   "upload_status",							limit: 255
		t.string   "upload_number",							limit: 255
    t.datetime "upload_datetime"         
		t.string   "uploaded_by",								limit: 255

 		t.string   "location_created_at",       limit: 250,              null: false
    t.string   "district_created_at",       limit: 250,              null: false
    t.string   "ta_created_at",      				limit: 250,              null: false
    t.string   "creator",       						limit: 250,              null: false

    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

end
