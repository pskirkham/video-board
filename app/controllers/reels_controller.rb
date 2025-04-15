class ReelsController < ApplicationController
  before_action :set_reel, only: %i[show edit update destroy publish playlist]

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
    if @reel.publish
      redirect_to @reel, notice: "Reel was successfully published."
    else
      redirect_to @reel, alert: "Cannot publish an empty reel."
    end
  end

  def playlist
    playlist = @reel.hls_playlist
    if playlist&.blob.present?
      # Set CORS headers to allow video player access
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Origin, Accept, Content-Type"

      # Set content type and disposition
      response.headers["Content-Type"] = "application/x-mpegURL"
      send_data playlist.blob.download, filename: "playlist.m3u8", disposition: "inline"
    else
      head :not_found
    end
  end

  private

  def set_reel
    @reel = Reel.find(params[:id])
  end

  def reel_params
    params.require(:reel).permit(:name, clips_attributes: %i[id video position _destroy])
  end
end
