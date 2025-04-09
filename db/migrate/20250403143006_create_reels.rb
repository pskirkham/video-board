class CreateReels < ActiveRecord::Migration[8.0]
  def change
    create_table :reels do |t|
      t.string :name

      t.timestamps
    end
  end
end
