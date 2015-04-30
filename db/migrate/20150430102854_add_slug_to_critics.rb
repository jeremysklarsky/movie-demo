class AddSlugToCritics < ActiveRecord::Migration
  def change
    add_column :critics, :slug, :string
  end
end
