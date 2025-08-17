class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :partner, null: false, foreign_key: { to_table: :users }
      t.string :key, null: false

      t.timestamps
    end

    add_index :chats, :key, unique: true
    add_index :chats, [:user_id, :partner_id]
  end
end
