module ApplicationHelper
  def weekday_mixed_abbr(date)
    map = {
      0 => "Su", # Sunday
      1 => "M",  # Monday
      2 => "Tu", # Tuesday
      3 => "W",  # Wednesday
      4 => "Th", # Thursday
      5 => "F",  # Friday
      6 => "Sa"  # Saturday
    }
    map[date.wday]
  end
end
