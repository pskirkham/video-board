class Reel < ApplicationRecord
  has_many :clips, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :clips, allow_destroy: true
  validates :name, presence: true
end
