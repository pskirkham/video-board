class Clip < ApplicationRecord
  belongs_to :reel
  has_one_attached :video

  acts_as_list scope: :reel

  validates :video, presence: true

  after_create_commit :analyze_video
  after_create_commit :generate_thumbnail

  def h264? = codec == "h264"

  def resolution
    "#{width}x#{height}" if width.present? && height.present?
  end

  private

  def analyze_video
    return unless video.attached?

    # Download the video to a temporary file
    Tempfile.create(["video", File.extname(video.filename.to_s)]) do |file|
      file.binmode
      file.write(video.download)
      file.rewind

      codec = `ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 #{file.path}`.strip

      dimensions = `ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x #{file.path}`.strip
      width, height = dimensions.split("x").map(&:to_i)

      duration = `ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 #{file.path}`.strip.to_d

      update_columns(codec:, width:, height:, duration:)
    end
  end

  def generate_thumbnail
    return unless video.attached?

    GenerateThumbnailJob.perform_later(id)
  end
end
