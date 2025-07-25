class CreateFeedback < ActiveRecord::Migration[7.1]
  def change
    create_table :feedbacks do |t|
      t.string :outfit_id
      t.string :comment
      t.integer :score
      t.timestamps
    end
  end
end
