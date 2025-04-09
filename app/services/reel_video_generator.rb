# app/services/reel_video_generator.rb
class ReelVideoGenerator
  CROSSFADE_DURATION = 1
  RESOLUTION = "1280:720".freeze
  FPS = 24
  SCALE_FILTER = "scale=#{RESOLUTION}:force_original_aspect_ratio=increase,crop=#{RESOLUTION},format=yuv420p,setpts=PTS-STARTPTS,fps=#{FPS}".freeze

  def self.generate(reel)
    `mkdir -p tmp`
    `mkdir -p tmp/reels`
    `cd tmp/reels && #{ffmpeg_command(reel)}`
  end

  def self.ffmpeg_command(reel)
    inputs = []
    filter_cmds = []
    durations = []

    reel.reel_items.order(:position).each_with_index do |item, idx|
      path = item.file_path
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

    filename = "reel_#{reel.id}_#{reel.updated_at.to_i}.mp4"

    "ffmpeg #{inputs.join(" ")} #{filter_complex} -map \"#{final_map}\" -c:v libx264 -pix_fmt yuv420p -r #{FPS} -movflags +faststart #{filename}"
  end
end
