class CreateClips < ActiveRecord::Migration[7.1]
  def change
    create_table :clips do |t|
      t.references :reel, null: false, foreign_key: true
      t.integer :position
      t.timestamps
    end

    add_index :clips, %i[reel_id position]
  end
end
