class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :name
      t.integer :score
      t.date :release_date
      t.string :thumbnail_url
      t.text :summary
      t.string :runtime
      t.string :metacritic_url

      t.timestamps null: false
    end
  end
end
