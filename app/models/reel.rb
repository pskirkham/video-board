class Reel < ApplicationRecord
  has_many :reel_items, -> { order(:position) }, dependent: :destroy
  has_one_attached :video
  accepts_nested_attributes_for :reel_items, allow_destroy: true
end
