class AddIndexToCriticReviews < ActiveRecord::Migration
  def change

    add_index :critic_reviews, :critic_id
    add_index :critic_reviews, :movie_id
    add_index :critic_reviews, [:critic_id, :movie_id], unique: true

  end
end
