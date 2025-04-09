class AddDurationToReelItems < ActiveRecord::Migration[8.0]
  def change
    add_column :reel_items, :duration, :integer
  end
end
