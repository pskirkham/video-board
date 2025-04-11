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

  def flash_class(type)
    case type.to_sym
    when :notice
      "bg-blue-100 text-blue-800 border border-blue-400"
    when :alert
      "bg-red-100 text-red-800 border border-red-400"
    when :success
      "bg-green-100 text-green-800 border border-green-400"
    else
      "bg-gray-100 text-gray-800 border border-gray-400"
    end
  end
end
