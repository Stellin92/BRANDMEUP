class AddColorSetToOutfits < ActiveRecord::Migration[7.1]
  def change
    add_column :outfits, :color_set, :string, array: true, default: []
  end
end
