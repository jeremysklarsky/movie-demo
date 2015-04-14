class CreateCriticPublications < ActiveRecord::Migration
  def change
    create_table :critic_publications do |t|
      t.integer :critic_id
      t.integer :publication_id

      t.timestamps null: false
    end
  end
end
