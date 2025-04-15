class HlsConverter
  HLS_DIR = "hls"
  SEGMENT_DURATION = 10 # seconds

  def initialize(reel)
    @reel = reel
  end

  def convert
    return if @reel.clips.empty?

    # Create temporary directory for processing
    Dir.mktmpdir do |tmp_dir|
      # Download all clips
      clip_paths = download_clips(tmp_dir)

      # Create concatenated video
      concat_path = create_concat_file(clip_paths, tmp_dir)
      output_path = File.join(tmp_dir, "output.mp4")

      # Convert to HLS
      convert_to_hls(concat_path, output_path, tmp_dir)

      # Upload HLS files to S3
      upload_hls_files(tmp_dir)
    end
  end

  private

  def download_clips(tmp_dir)
    @reel.clips.map do |clip|
      path = File.join(tmp_dir, "clip_#{clip.id}.mp4")
      File.open(path, "wb") do |file|
        file.write(clip.video.download)
      end
      path
    end
  end

  def create_concat_file(clip_paths, tmp_dir)
    concat_path = File.join(tmp_dir, "concat.txt")
    File.open(concat_path, "w") do |file|
      clip_paths.each do |path|
        file.puts("file '#{path}'")
      end
    end
    concat_path
  end

  def convert_to_hls(input_path, output_path, tmp_dir)
    hls_dir = File.join(tmp_dir, HLS_DIR)
    Dir.mkdir(hls_dir)

    # First convert to a single MP4
    system("ffmpeg -f concat -safe 0 -i #{input_path} -c copy #{output_path}")

    # Then convert to HLS
    system("ffmpeg -i #{output_path} \
      -profile:v baseline -level 3.0 \
      -start_number 0 \
      -hls_time #{SEGMENT_DURATION} \
      -hls_list_size 0 \
      -f hls \
      #{File.join(hls_dir, "playlist.m3u8")}")
  end

  def upload_hls_files(tmp_dir)
    hls_dir = File.join(tmp_dir, HLS_DIR)
    Dir.glob(File.join(hls_dir, "*")).each do |file|
      next if File.directory?(file)

      filename = File.basename(file)
      @reel.hls_files.attach(
        io: File.open(file),
        filename: filename,
        content_type: filename.end_with?(".m3u8") ? "application/x-mpegURL" : "video/MP2T"
      )
    end
  end
end
