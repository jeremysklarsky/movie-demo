class AddPublicationToCriticReviews < ActiveRecord::Migration
  def change
    add_column :critic_reviews, :publication_id, :integer
  end
end
