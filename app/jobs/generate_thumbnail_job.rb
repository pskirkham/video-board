class GenerateThumbnailJob < ApplicationJob
  queue_as :default

  def perform(clip_id)
    clip = Clip.find(clip_id)
    return unless clip.video.attached?

    clip.video.preview(resize_to_fill: [640, 360]).processed
  end
end
