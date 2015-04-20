class CreateSimilarityScores < ActiveRecord::Migration
  def change
    create_table :similarity_scores do |t|
      t.integer :user_id
      t.integer :critic_id
      t.float :similarity_score
      t.integer :review_count
    end
  end
end
