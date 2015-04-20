class CreateMovieFacts < ActiveRecord::Migration
  def change
    create_table :movie_facts do |t|
      t.string :content

      t.timestamps null: false
    end
  end
end
