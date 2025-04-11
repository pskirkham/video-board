class GenerateReelVideoJob < ApplicationJob
  queue_as :default

  CROSSFADE_DURATION = 1
  RESOLUTION = "1280:720".freeze
  FPS = 24
  SCALE_FILTER = "scale=#{RESOLUTION}:force_original_aspect_ratio=increase,crop=#{RESOLUTION},format=yuv420p,setpts=PTS-STARTPTS,fps=#{FPS}".freeze

  def perform(reel_id)
    reel = Reel.find(reel_id)
    return unless reel.reel_items.any?

    # Create a temporary directory for processing
    Dir.mktmpdir do |dir|
      # Download all media files
      media_files = download_media_files(reel, dir)

      # Generate the video
      output_path = File.join(dir, "reel_#{reel.id}_#{reel.updated_at.to_i}.mp4")
      generate_video(reel, media_files, output_path)

      # Attach the video to the reel
      attach_video(reel, output_path)
    end
  end

  private

  def download_media_files(reel, dir)
    reel.reel_items.map do |item|
      next unless item.file.attached?

      file_path = File.join(dir, "#{item.id}#{File.extname(item.filename)}")
      item.file.download do |chunk|
        File.open(file_path, "ab") { |f| f.write(chunk) }
      end

      { path: file_path, duration: item.duration || item.video_duration, item_id: item.id }
    end.compact
  end

  def generate_video(reel, media_files, output_path)
    command = ffmpeg_command(reel, media_files, output_path)
    logger.info "Generated ffmpeg command: #{command}"
    system(command)
  end

  def ffmpeg_command(reel, media_files, output_path)
    inputs = []
    filter_cmds = []
    durations = []

    reel.reel_items.each_with_index do |item, idx|
      media_file = media_files.find { |m| m[:item_id] == item.id }
      unless media_file
        logger.error "Could not find media file for item #{item.id}"
        next
      end

      path = media_file[:path]
      logger.info "Processing item #{item.id} with path: #{path}"

      if item.image?
        d = item.duration.to_i
        inputs << "-loop 1 -t #{d} -i #{path}"
      elsif item.video?
        d = item.video_duration.to_i
        inputs << "-i #{path}"
      else
        next
      end
      durations << d
      filter_cmds << "[#{idx}:v]#{SCALE_FILTER}[v#{idx}]"
    end

    return "echo 'No valid inputs'" if filter_cmds.empty?

    if filter_cmds.size == 1
      final_map = "[v0]"
      xfade_chain = ""
    else
      xfade_chain = []
      current = "v0"
      (1...filter_cmds.size).each do |i|
        offset = durations[0...i].sum - i * CROSSFADE_DURATION
        next_label = "x#{i}"
        xfade_chain << "[#{current}][v#{i}]xfade=transition=fade:duration=#{CROSSFADE_DURATION}:offset=#{offset}[#{next_label}]"
        current = next_label
      end
      final_map = "[#{current}]"
    end

    filter_complex = "-filter_complex \"#{(filter_cmds + xfade_chain).join("; ")}\""

    "ffmpeg #{inputs.join(" ")} #{filter_complex} -map \"#{final_map}\" -c:v libx264 -pix_fmt yuv420p -r #{FPS} -movflags +faststart #{output_path}"
  end

  def attach_video(reel, video_path)
    reel.video.attach(
      io: File.open(video_path),
      filename: "reel_#{reel.id}.mp4",
      content_type: "video/mp4"
    )
  end
end
