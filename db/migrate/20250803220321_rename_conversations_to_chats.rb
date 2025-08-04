class RenameConversationsToChats < ActiveRecord::Migration[7.1]
  def change
    rename_table :conversation, :chats
  end
end
