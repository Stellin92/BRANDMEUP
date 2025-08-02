class AddItemsListToOutfits < ActiveRecord::Migration[7.1]
  def change
    add_column :outfits, :items_list, :string, array: true, default: []
  end
end
