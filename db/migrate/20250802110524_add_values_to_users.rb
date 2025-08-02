class AddValuesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :values, :string, array: true,default: []
  end
end
