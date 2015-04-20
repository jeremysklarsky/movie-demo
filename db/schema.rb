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

ActiveRecord::Schema.define(version: 20150420014505) do

  create_table "critic_publications", force: :cascade do |t|
    t.integer  "critic_id"
    t.integer  "publication_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "critic_reviews", force: :cascade do |t|
    t.integer  "critic_id"
    t.integer  "movie_id"
    t.integer  "score"
    t.string   "excerpt"
    t.string   "link"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "publication_id"
  end

  add_index "critic_reviews", ["critic_id", "movie_id"], name: "index_critic_reviews_on_critic_id_and_movie_id", unique: true
  add_index "critic_reviews", ["critic_id"], name: "index_critic_reviews_on_critic_id"
  add_index "critic_reviews", ["movie_id"], name: "index_critic_reviews_on_movie_id"

  create_table "critics", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_genres", force: :cascade do |t|
    t.integer  "movie_id"
    t.integer  "genre_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movies", force: :cascade do |t|
    t.string   "name"
    t.integer  "score"
    t.date     "release_date"
    t.string   "thumbnail_url"
    t.text     "summary"
    t.string   "runtime"
    t.string   "metacritic_url"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "publications", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "similarity_scores", force: :cascade do |t|
    t.integer "user_id"
    t.integer "critic_id"
    t.float   "similarity_score"
    t.integer "review_count"
  end

  create_table "user_reviews", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "movie_id"
    t.integer  "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_reviews", ["movie_id"], name: "index_user_reviews_on_movie_id"
  add_index "user_reviews", ["user_id", "movie_id"], name: "index_user_reviews_on_user_id_and_movie_id", unique: true
  add_index "user_reviews", ["user_id"], name: "index_user_reviews_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
