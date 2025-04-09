class ReelItem < ApplicationRecord
  belongs_to :reel
  has_one_attached :file
  acts_as_list scope: :reel

  before_validation :remove_duration_for_non_photos
  after_commit :generate_thumbnail, on: %i[create update], if: -> { file.attached? }

  validate :duration_required_for_photos

  def image? = file.attached? && file.content_type.start_with?("image/")
  def video? = file.attached? && file.content_type.start_with?("video/")

  def video_duration
    return unless video?

    file.analyze unless file.analyzed?
    file.metadata["duration"]&.to_i
  end

  def file_path
    return unless file.attached?

    service = file.blob.service
    if service.is_a? ActiveStorage::Service::DiskService
      service.path_for file.blob.key
    else
      file.service_url expires_in: 1.hour, disposition: "inline"
    end
  end

  def filename
    file.blob.filename.to_s if file.attached?
  end

  def digest
    Digest::SHA1.hexdigest([file.blob&.key, duration, video_duration].join(";"))
  end

  private

  def duration_required_for_photos
    errors.add(:duration, "must be specified for photo attachments") if duration.blank? && image?
    errors.add(:duration, "must be between 1 and 60 seconds") if duration.present? && !duration.between?(1, 60)
  end

  def remove_duration_for_non_photos
    self.duration = nil if file.attached? && !file.content_type.start_with?("image/")
  end

  def generate_thumbnail
    if image?
      file.variant(resize_to_fill: [640, 360]).processed
    elsif video?
      file.preview(resize_to_fill: [640, 360]).processed
    end
  end
end
