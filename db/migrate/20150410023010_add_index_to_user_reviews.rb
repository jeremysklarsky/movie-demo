class AddIndexToUserReviews < ActiveRecord::Migration
  def change
    add_index :user_reviews, :user_id
    add_index :user_reviews, :movie_id
    add_index :user_reviews, [:user_id, :movie_id], unique: true

  end
end
