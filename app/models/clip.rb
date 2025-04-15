class Clip < ApplicationRecord
  belongs_to :reel
  has_one_attached :video

  acts_as_list scope: :reel

  validates :video, presence: true

  after_create_commit :analyze_video
  after_create_commit :generate_thumbnail

  def h264?
    codec == "h264"
  end

  private

  def analyze_video
    return unless video.attached?

    codec = `ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 #{video_path}`
    update_column(:codec, codec.strip)
  end

  def generate_thumbnail
    return unless video.attached?

    GenerateThumbnailJob.perform_later(id)
  end

  def video_path
    ActiveStorage::Blob.service.path_for(video.key)
  end
end
