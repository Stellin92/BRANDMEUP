class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.date :date
      t.references :user, null: false, foreign_key: true
      t.references :partner, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
