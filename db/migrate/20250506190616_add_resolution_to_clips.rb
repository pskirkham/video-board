class AddResolutionToClips < ActiveRecord::Migration[8.0]
  def change
    add_column :clips, :width, :integer
    add_column :clips, :height, :integer
  end
end
