class FeedsController < ApplicationController
  def index
    @reels = Reel.all.includes(:clips)
  end
end
