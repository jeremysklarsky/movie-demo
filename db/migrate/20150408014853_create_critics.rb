class CreateCritics < ActiveRecord::Migration
  def change
    create_table :critics do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
