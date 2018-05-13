class CreateRecipe < ActiveRecord::Migration
  def change
    create_table  :recipes do |t|
      t.string :name
      t.string :ingredients
      t.string :flavor
      t.string :type
      t.string :url
    end
  end
end
