class Reel < ApplicationRecord
  has_many :clips, -> { order(position: :asc) }, dependent: :destroy
  has_many_attached :hls_files
  accepts_nested_attributes_for :clips, allow_destroy: true
  validates :name, presence: true

  def publish
    return false if clips.empty?

    hls_files.purge
    HlsConverter.new(self).convert
  end

  def hls_playlist
    hls_files.find { |file| file.filename.to_s == "playlist.m3u8" }
  end

  def hls_segments
    hls_files.select { |file| file.filename.to_s.end_with?(".ts") }
  end
end
