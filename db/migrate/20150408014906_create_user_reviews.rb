class CreateUserReviews < ActiveRecord::Migration
  def change
    create_table :user_reviews do |t|
      t.integer :user_id
      t.integer :movie_id
      t.integer :score
      t.timestamps null: false
    end
  end

end
