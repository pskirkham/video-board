class CreateReelItems < ActiveRecord::Migration[8.0]
  def change
    create_table :reel_items do |t|
      t.references :reel, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
