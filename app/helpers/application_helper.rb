module ApplicationHelper
  def weekday_mixed_abbr(date)
    map = {
      0 => "Sun.", # Sunday
      1 => "Mon.",  # Monday
      2 => "Tue.", # Tuesday
      3 => "Wed.",  # Wednesday
      4 => "Thu.", # Thursday
      5 => "Fri.",  # Friday
      6 => "Sat."  # Saturday
    }
    map[date.wday]
  end
end
