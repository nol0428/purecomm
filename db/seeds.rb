puts "Clearing existing data..."
Partnership.destroy_all
User.destroy_all
puts "== Seeding deterministic demo data =="

# --- Helpers ---------------------------------------------------------------

def create_users!
  paul = User.find_or_create_by!(email: "paul@email.com") do |u|
    u.username     = "Paul"
    u.password     = "password"
    u.personality  = "Melancholic"
    u.love_language = "Words of Affirmation"
    u.pronouns     = "He/Him"
    u.hobbies      = "Cycling, beer, motorsports"
    u.birthday     = Date.new(1983, 4, 10)
  end

  mai = User.find_or_create_by!(email: "mai@email.com") do |u|
    u.username     = "Mai"
    u.password     = "password"
    u.personality  = "Sanguine"
    u.love_language = "Physical Touch"
    u.pronouns     = "She/Her"
    u.hobbies      = "Foodie, travel, shopping"
    u.birthday     = Date.new(1989, 6, 23)
  end

  [paul, mai]
end

def create_partnership!(a, b)
  # If your model allows only one row per pair (regardless of order), you might
  # want a unique validation at the DB level. For now, we find-or-create on the tuple.
  Partnership.find_or_create_by!(user_one: a, user_two: b)
end

def upsert_checkins!(user:, partnership:, rows:)
  # We use (user_id + created_on + comment) as a "stable key" to avoid duplicates.
  rows.each do |r|
    created_at = r.fetch(:created_at) # Date or Time
    key = {
      user_id: user.id,
      partnership_id: partnership.id,
      # store by day to keep uniqueness even if times vary
      created_at: created_at.beginning_of_day..created_at.end_of_day
    }

    existing = Checkin.where(user: user, partnership: partnership)
                      .where(created_at: key[:created_at])
                      .where(comment: r[:comment])
                      .first

    checkin = existing || Checkin.new(user: user, partnership: partnership, created_at: created_at)
    checkin.mood     = r[:mood]
    checkin.my_day   = r[:my_day]
    checkin.discuss  = r[:discuss]
    checkin.comment  = r[:comment]
    checkin.nudge    = r[:nudge]
    checkin.save!
  end
end

def upsert_grievances!(rows:, partnership:)
  # Use (user_id + topic + situation) as a "stable key"
  rows.each do |r|
    g = Grievance.find_or_initialize_by(
      user_id: r[:user].id,
      partnership_id: partnership.id,
      topic: r[:topic],
      situation: r[:situation] # ← comma removed issue fixed by line end
    )

    # Only set created_at when first created or when you explicitly pass it
    if g.new_record?
      g.created_at = r[:created_at] || (Time.zone.now - rand(4..15).days)
    elsif r[:created_at]
      # If you want explicit control even on existing rows, allow override:
      g.created_at = r[:created_at]
    end

    g.feeling         = r[:feeling]
    g.intensity_scale = r[:intensity_scale]
    g.save!
  end
end

# --- Build data ------------------------------------------------------------

ActiveRecord::Base.transaction do
  paul, mai = create_users!
  partnership = create_partnership!(paul, mai)

  # Hand-written checkins (EXAMPLES — edit these)
  # Tip: use Date.today - n for relative days, or set explicit dates for your demo.
  paul_checkins = [
    { created_at: Date.today - 6, mood: "Fine", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-08-30 20:00") },
    { created_at: Date.today - 5, mood: "Fine", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-08-31 20:00") },
    { created_at: Date.today - 4, mood: "Upset", my_day: "Bad", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-01 20:00") },
    { created_at: Date.today - 3, mood: "Upset", my_day: "Bad", discuss: false,
      comment: "My subordinate is a moron.", nudge: Time.zone.parse("2025-09-02 20:00") },
    { created_at: Date.today - 2, mood: "Tired", my_day: "Bad", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-03 20:00") },
    { created_at: Date.today - 1, mood: "Tired", my_day: "Bad", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-04 20:00") }
  ]

  mai_checkins = [
    { created_at: Date.today - 6, mood: "Happy", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-08-30 19:00") },
    { created_at: Date.today - 5, mood: "Happy", my_day: "Good", discuss: false,
      comment: "Yummy lunch spot.", nudge: Time.zone.parse("2025-08-31 19:00") },
    { created_at: Date.today - 4, mood: "Tired", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-01 19:00") },
    { created_at: Date.today - 3, mood: "Fine", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-02 19:00") },
    { created_at: Date.today - 2, mood: "Fine", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-03 19:00") },
    { created_at: Date.today - 1, mood: "Happy", my_day: "Good", discuss: true,
      comment: "PJ's Sports Festival Day practice was so cute. The teachers asked us to volunteer and I'm excited for it.", nudge: Time.zone.parse("2025-09-04 19:00") }
  ]

  upsert_checkins!(user: paul, partnership: partnership, rows: paul_checkins)
  upsert_checkins!(user: mai,  partnership: partnership, rows: mai_checkins)

  # Hand-written grievances (EXAMPLES — edit these)
  grievances = [
    { user: paul, feeling: "Upset",   topic: "Laundry",        intensity_scale: 3,
      situation: "I feel like I keep folding laundry after long days." },
    { user: mai,  feeling: "Sad",     topic: "Communication",  intensity_scale: 4,
      situation: "We haven't really talked this week and it makes me lonely." },
    { user: paul, feeling: "Anxious", topic: "Money",          intensity_scale: 5,
      situation: "I'm worried about unexpected expenses lately." },
    { user: mai,  feeling: "Tired",   topic: "Chores",         intensity_scale: 3,
      situation: "I asked about the trash a few times and it's still there." },
    { user: paul, feeling: "Tired",     topic: "Social meter",  intensity_scale: 4,
      situation: "I don't like when I am obligated to go when make dinner plans with your friends. I don't have the energy or patience to entertain them every weekend" },
    { user: mai,  feeling: "Upset",   topic: "Work-life balance",      intensity_scale: 3,
      situation: "Late work nights make dinners together rare." }
  ].map { |h| h.merge(partnership: partnership) }

  upsert_grievances!(rows: grievances, partnership: partnership)
end

puts "== Done. Users: #{User.count}, Partnership: #{Partnership.count}, Checkins: #{Checkin.count}, Grievances: #{Grievance.count} =="
