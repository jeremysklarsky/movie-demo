class CreateCriticReviews < ActiveRecord::Migration
  def change
    create_table :critic_reviews do |t|
      t.integer :critic_id
      t.integer :movie_id
      t.integer :score
      t.string :excerpt
      t.string :link

      t.timestamps null: false
    end
  end


end
