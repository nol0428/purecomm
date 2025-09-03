module CheckinsHelper
  def checkin_summary(checkin)
    name = checkin.user.username
    mood = checkin.mood.to_s.downcase.presence      # e.g., "tired"
    day  = checkin.respond_to?(:my_day) ? checkin.my_day.to_s.downcase.presence : nil

    day_phrase =
      case day
      when "good" then "a good day"
      when "bad"  then "a bad day"
      else nil
      end

    if day_phrase && mood
      "#{name} had #{day_phrase} and felt #{mood}."
    elsif day_phrase
      "#{name} had #{day_phrase}."
    elsif mood
      "#{name} felt #{mood}."
    else
      "#{name} checked in."
    end
  end
end
