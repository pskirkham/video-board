class ReelsController < ApplicationController
  before_action :set_reel, only: %i[show edit update destroy publish delete_video]

  def index
    @reels = Reel.all
  end

  def show
  end

  def new
    @reel = Reel.new
  end

  def edit
  end

  def create
    @reel = Reel.new(reel_params)

    if @reel.save
      redirect_to @reel, notice: "Reel was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @reel.update(reel_params)
      redirect_to @reel, notice: "Reel was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reel.destroy
    redirect_to reels_url, notice: "Reel was successfully destroyed."
  end

  def publish
    @reel.video.purge
    GenerateReelVideoJob.perform_later(@reel.id)
    redirect_to @reel, notice: "Video generation has been started."
  end

  def delete_video
    @reel.video.purge
    redirect_to @reel, notice: "Video was successfully deleted."
  end

  private

  def set_reel
    @reel = Reel.find(params[:id])
  end

  def reel_params
    params.require(:reel).permit(:name, reel_items_attributes: %i[id file duration position _destroy])
  end
end
