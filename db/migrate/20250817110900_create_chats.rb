class CreateChats < ActiveRecord::Migration[7.1]
  def up
    # 1) Créer la table si elle n'existe pas
    create_table :chats, if_not_exists: true do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :partner, null: false, foreign_key: { to_table: :users }
      # On mettra :key via add_column ci-dessous pour gérer le cas "table déjà existante"
      t.timestamps
    end

    # 2) S'assurer que la colonne :key existe
    unless column_exists?(:chats, :key)
      add_column :chats, :key, :string # <- temporairement nullable pour pouvoir backfiller
    end

    # 3) Backfill des clés manquantes (unique et déterministe)
    execute <<~SQL
      UPDATE chats
         SET key = md5(user_id::text || '-' || partner_id::text || '-' || id::text)
       WHERE key IS NULL;
    SQL

    # 4) Contrainte NOT NULL (+ index unique)
    change_column_null :chats, :key, false
    add_index :chats, :key, unique: true unless index_exists?(:chats, :key, unique: true)

    # 5) Index et FKs si absents
    add_index :chats, [:user_id, :partner_id] unless index_exists?(:chats, [:user_id, :partner_id])
    add_foreign_key :chats, :users                      unless foreign_key_exists?(:chats, :users)
    add_foreign_key :chats, :users, column: :partner_id unless foreign_key_exists?(:chats, :users, column: :partner_id)
  end

  def down
    drop_table :chats, if_exists: true
  end
end
