class AddCodecToClips < ActiveRecord::Migration[7.1]
  def change
    add_column :clips, :codec, :string
  end
end
