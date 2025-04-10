class GenerateThumbnailJob < ApplicationJob
  queue_as :default

  def perform(reel_item_id)
    reel_item = ReelItem.find(reel_item_id)
    return unless reel_item.file.attached?

    if reel_item.image?
      reel_item.file.variant(resize_to_fill: [640, 360]).processed
    elsif reel_item.video?
      reel_item.file.preview(resize_to_fill: [640, 360]).processed
    end
  end
end
