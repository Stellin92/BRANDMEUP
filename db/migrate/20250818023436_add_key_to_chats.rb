class AddKeyToChats < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :key, :string, null: false
    add_index  :chats, :key, unique: true
  end
end
