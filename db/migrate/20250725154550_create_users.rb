class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :talent, :string
    add_column :users, :avatar_url, :string
    add_column :users, :bio, :string
    add_column :users, :values, :string
  end
end
