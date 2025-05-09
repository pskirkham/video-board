class AddDurationToClips < ActiveRecord::Migration[8.0]
  def change
    add_column :clips, :duration, :decimal, precision: 10, scale: 6
  end
end
