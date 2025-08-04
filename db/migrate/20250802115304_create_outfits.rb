class CreateOutfits < ActiveRecord::Migration[7.1]
  def change
    create_table :outfits do |t|
      t.string :title
      t.text :description
      t.boolean :public
      t.string :style
      t.string :goal
      t.string :outfit_image_url
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
