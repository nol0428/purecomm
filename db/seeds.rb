# db/seeds.rb
# Deterministic seeds for demo (no randomness)

puts "Clearing existing data..."
Partnership.destroy_all
User.destroy_all

puts "== Seeding deterministic demo data =="

# --- Helpers ---------------------------------------------------------------
def day_at(days_ago, hour, min = 0, sec = 0)
  (Time.zone.now - days_ago.days).change(hour: hour, min: min, sec: sec)
end

def create_users!
  paul = User.find_or_create_by!(email: "paul@email.com") do |u|
    u.username      = "Paul"
    u.password      = "password"
    u.personality   = { Sanguine: 0.15, Choleric: 0.25, Melancholic: 0.40, Phlegmatic: 0.20 }
    u.love_language = "Words of Affirmation"
  end

  mai = User.find_or_create_by!(email: "mai@email.com") do |u|
    u.username      = "Mai"
    u.password      = "password"
    u.personality   = { Sanguine: 0.15, Choleric: 0.25, Melancholic: 0.40, Phlegmatic: 0.20 }
    u.love_language = "Quality Time"
  end

  [paul, mai]
end

def create_partnership!(a, b)
  Partnership.find_or_create_by!(user_one: a, user_two: b)
end

def upsert_checkins!(user:, partnership:, rows:)
  rows.each do |r|
    created_at = r.fetch(:created_at) # Time
    # Keep rows idempotent by matching on same day + same comment (can be nil)
    existing = Checkin.where(user: user, partnership: partnership)
                      .where(created_at: created_at.beginning_of_day..created_at.end_of_day)
                      .where(comment: r[:comment])
                      .first

    checkin = existing || Checkin.new(user: user, partnership: partnership, created_at: created_at)
    checkin.mood     = r[:mood]
    checkin.my_day   = r[:my_day]
    checkin.discuss  = r[:discuss]
    checkin.comment  = r[:comment]

    # AUTO: if you didn’t specify nudge, set it to 2h after created_at (same behavior as your old seeds intent)
    checkin.nudge    = r[:nudge] || (created_at + 2.hours)

    checkin.save!
  end
end

def upsert_grievances!(rows:, partnership:)
  rows.each do |r|
    g = Grievance.find_or_initialize_by(
      user_id:        r[:user].id,
      partnership_id: partnership.id,
      topic:          r[:topic],
      situation:      r[:situation]
    )

    if g.new_record?
      g.created_at = r[:created_at] || (Time.zone.now - rand(4..15).days)
    elsif r[:created_at]
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

# Helper to create a timestamp relative to today with a fixed hour
def at_hour_relative(days_ago, hour)
  date = Date.today - days_ago
  Time.zone.local(date.year, date.month, date.day, hour, 0, 0)
end

  # Paul’s check-ins
  paul_checkins = [
    { created_at: day_at(6, 20), mood: "Fine", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-08-30 20:00") },
    { created_at: day_at(5, 20), mood: "Fine", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-08-31 20:00") },
    { created_at: day_at(4, 20), mood: "Upset", my_day: "Bad", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-01 20:00") },
    { created_at: day_at(3, 20), mood: "Upset", my_day: "Bad", discuss: false,
      comment: "My subordinate is a moron.", nudge: Time.zone.parse("2025-09-02 20:00") },
    { created_at: day_at(2, 20), mood: "Tired", my_day: "Bad", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-03 20:00") },
    { created_at: day_at(1, 20), mood: "Tired", my_day: "Bad", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-04 20:00") }
  ]

  # Mai’s check-ins
  mai_checkins = [
    { created_at: day_at(6, 19), mood: "Happy", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-08-30 19:20") },
    { created_at: day_at(5, 19), mood: "Happy", my_day: "Good", discuss: false,
      comment: "Yummy lunch spot.", nudge: Time.zone.parse("2025-08-31 19:45") },
    { created_at: day_at(4, 19), mood: "Tired", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-01 20:00") },
    { created_at: day_at(3, 19), mood: "Fine", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-02 17:01") },
    { created_at: day_at(2, 19), mood: "Fine", my_day: "Good", discuss: false,
      comment: nil, nudge: Time.zone.parse("2025-09-03 19:10") },
    { created_at: day_at(1, 19), mood: "Happy", my_day: "Good", discuss: true,
      comment: "I saw some of PJ's Sports Festival Day practice and it was so cute. The teachers asked us to volunteer and I'm really excited. We need to figure out our schedules so we can help out.", nudge: Time.zone.parse("2025-09-04 19:00") }
  ]

  upsert_checkins!(user: paul, partnership: partnership, rows: paul_checkins)
  upsert_checkins!(user: mai,  partnership: partnership, rows: mai_checkins)

  grievances = [
    { user: paul, feeling: "Upset",   topic: "Laundry",        intensity_scale: 3,
      situation: "I feel like I keep folding laundry after long days.", created_at: day_at(6, 21) },
    { user: mai,  feeling: "Sad",     topic: "Your pint glass",  intensity_scale: 4,
      situation: "You keep leaving your pint glass on the coffee table in the living room", created_at: day_at(5, 18, 30) },
    { user: paul, feeling: "Anxious", topic: "Finances",          intensity_scale: 5,
      situation: "I’m worried about unexpected expenses lately.", created_at: day_at(4, 20) },
    { user: mai,  feeling: "Tired",   topic: "Chores",         intensity_scale: 3,
      situation: "I asked about the trash a few times and it’s still there.", created_at: day_at(3, 19) },
    { user: paul, feeling: "Tired",     topic: "Social meter",  intensity_scale: 4,
      situation: "I don't like when I am obligated to go when make dinner plans with your friends. I don't have the energy or patience to entertain them every weekend", created_at: day_at(2, 22) },
    { user: mai,  feeling: "Upset",   topic: "Work-life balance",      intensity_scale: 3,
      situation: "Late work nights make dinners together rare.", created_at: day_at(1, 20, 15) }
  ].map { |h| h.merge(partnership: partnership) }

  upsert_grievances!(rows: grievances, partnership: partnership)
end

puts "== Done. Users: #{User.count}, Partnership: #{Partnership.count}, Checkins: #{Checkin.count}, Grievances: #{Grievance.count} =="
