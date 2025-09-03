module GrievancesHelper
  def grievance_feelings_options
    [
      ["Tired", "tired"],
      ["Sad", "sad"],
      ["Upset", "upset"],
      ["Anxious", "anxious"]
    ]
  end

  FEELING_MAP = {
    "tired"  => "Tired",
    "sad"    => "Sad",
    "upset"  => "Upset",
    "anxious"=> "Anxious"
  }.freeze

  def grievance_feeling_key(grievance)
    grievance.feeling.to_s.downcase
  end

  def grievance_feeling_label(grievance)
    FEELING_MAP[grievance_feeling_key(grievance)] || grievance.feeling.to_s.titleize
  end

  def grievance_feeling_icon(grievance)
    "#{grievance_feeling_key(grievance)}.svg"
  end
end
