module ApplicationHelper
  def duration_hms(total_seconds)
    total_seconds = total_seconds.to_i
    return "0s" if total_seconds == 0

    hours = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60

    parts = []
    parts << "#{hours}h" if total_seconds >= 3600
    parts << "#{minutes}m" if total_seconds >= 60
    parts << "#{seconds}s"

    parts.join
  end
end
