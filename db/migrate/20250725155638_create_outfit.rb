class CreateOutfit < ActiveRecord::Migration[7.1]
  def change
    create_table :outfits do |t|
      t.string :user_id
      t.string :title
      t.string :style
      t.string :color_set
      t.string :goal
      t.string :outfit_image_url
      t.string :items
      t.string :description
      t.timestamps
    end
  end
end
