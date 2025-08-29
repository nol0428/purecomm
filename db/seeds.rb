# # This file should ensure the existence of records required to run the application in every environment (production,
# # development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
# #
# # Example:
# #
# #   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
# #     MovieGenre.find_or_create_by!(name: genre_name)
# #   end
# MOODS = ["Happy", "Fine", "Tired", "Sad", "Upset", "Anxious"]
# MY_DAY = ["Good", "Bad"]
# MOOD_COMMENTS = {
#   "Happy" => [
#     "I feel so grateful today!",
#     "Everything seems to go my way.",
#     "The sunshine made my morning perfect."
#   ],
#   "Fine" => [
#     "Nothing special today, just an okay day.",
#     "I feel fine, not great but not bad either.",
#     "Everything's pretty normal, can't complain much."
#   ],
#   "Tired" => [
#     "I barely slept last night...",
#     "Work drained all my energy.",
#     "Need coffee, ASAP."
#   ],
#   "Sad" => [
#     "Feeling low, I just want to be alone today.",
#     "It's been a tough day, I can't shake this sadness.",
#     "I miss how things used to be, nothing feels right."
#   ],
#   "Upset" => [
#     "My clothes' brand were fake.",
#     "I am sick of my job.",
#     "We are spending too much money."
#   ],
#   "Anxious" => [
#     "Deadlines are killing me.",
#     "Too many things happening at once.",
#     "I can't catch a break."
#   ]
# }
# puts "Clearing existing data..."
# Partnership.destroy_all
# User.destroy_all
# puts "Creating users..."
# User.create(
#   username: "Paul",
#   email: "paul@email.com",
#   password: "password",
#   personality: "Melancholic",
#   love_language: "Words of Affirmation",
#   pronouns: "He/Him",
#   hobbies: "Cycling, beer, motorsports",
#   birthday: Date.new(1983, 4, 10)
# )
# User.create(
#   username: "Mai",
#   email: "mai@email.com",
#   password: "password",
#   personality: "Sanguine",
#   love_language: "Physical Touch",
#   pronouns: "She/Her",
#   hobbies: "Foodie, travel, shopping",
#   birthday: Date.new(1989, 6, 23)
# )
# puts "Creating the partnership"
# Partnership.create(
#   user_one: User.all[0],
#   user_two: User.all[1]
# )
# puts "Creating Checkins"
# (1..7).each do |num|
#   date = Date.today - num.day
#   one_mood = MOODS.sample
#   two_mood = MOODS.sample
#   Checkin.create!(
#     mood: one_mood,
#     my_day: MY_DAY.sample,
#     discuss: [true, false].sample,
#     comment: MOOD_COMMENTS[one_mood].sample,
#     created_at: date,
#     user: User.all[0],
#     partnership: Partnership.all.first,
#     nudge: DateTime.now + 2.hours
#     )
#   Checkin.create!(
#     mood: two_mood,
#     my_day: MY_DAY.sample,
#     discuss: [true, false].sample,
#     comment: MOOD_COMMENTS[two_mood].sample,
#     created_at: date,
#     user: User.all[1],
#     partnership: Partnership.all.first,
#     nudge: DateTime.now + 2.hours
#     )
#   end
# # Checkin.create(
# #   mood: "Tired",
# #   my_day: "Bad",
# #   discuss: false,
# #   comment: "I am sick of my job.",
# #   created_at: DateTime.now - 2.days,
# #   user: User.all[0],
# #   partnership: Partnership.all.first,
# #   nudge: DateTime.now + 2.hours
# #   )
# # Checkin.create!(
# #   mood: "Upset",
# #   my_day: "Bad",
# #   discuss: false,
# #   comment: "We are spending too much money",
# #   created_at: DateTime.now - 1.days,
# #   user: User.all[0],
# #   partnership: Partnership.all.first,
# #   nudge: DateTime.now + 2.hours
# #   )
# puts "Creating Grievances"
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Upset",
#   topic: "Laundry",
#   intensity_scale: 3,
#   partnership: Partnership.all.first,
#   situation: "Why do I always end up folding the laundry? It feels like you never notice how tired I am."
# )
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Sad",
#   topic: "Communication",
#   intensity_scale: 4,
#   partnership: Partnership.all.first,
#   situation: "I feel like we haven't really talked in days, and it makes me lonely."
# )
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Anxious",
#   topic: "Money",
#   intensity_scale: 5,
#   partnership: Partnership.all.first,
#   situation: "You keep spending without telling me, and I feel like I'm the only one worrying about our budget."
# )
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Sad",
#   topic: "Attention",
#   intensity_scale: 2,
#   partnership: Partnership.all.first,
#   situation: "When we go out, you're always on your phone. It makes me feel invisible."
# )
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Tired",
#   topic: "Chores",
#   intensity_scale: 3,
#   partnership: Partnership.all.first,
#   situation: "I asked you three times to take out the trash, and it's still sitting there. It makes me feel ignored."
# )
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Sad",
#   topic: "Time together",
#   intensity_scale: 4,
#   partnership: Partnership.all.first,
#   situation: "We keep canceling our plans, and I feel like spending time together isn't a priority anymore."
# )
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Tired",
#   topic: "Cleanliness",
#   intensity_scale: 3,
#   partnership: Partnership.all.first,
#   situation: "The sink is full of dirty dishes again. It feels like I'm the only one who cares about keeping things tidy."
# )
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Sad",
#   topic: "Affection",
#   intensity_scale: 4,
#   partnership: Partnership.all.first,
#   situation: "You don't hug or kiss me like you used to, and it makes me wonder if something's wrong."
# )
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Tired",
#   topic: "Responsibilities",
#   intensity_scale: 5,
#   partnership: Partnership.all.first,
#   situation: "I'm juggling work and home tasks, and I feel like I'm doing everything by myself."
# )
# Grievance.create!(
#   user: User.all.sample,
#   feeling: "Upset",
#   topic: "Work-life balance",
#   intensity_scale: 3,
#   partnership: Partnership.all.first,
#   situation: "You're always working late, and I miss having dinner together. I feel like we're growing apart."
# )
# puts "All done!"
# db/seeds.rb
# Deterministic seeds for demo (no randomness)
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
      situation: "We haven’t really talked this week and it makes me lonely." },
    { user: paul, feeling: "Anxious", topic: "Money",          intensity_scale: 5,
      situation: "I’m worried about unexpected expenses lately." },
    { user: mai,  feeling: "Tired",   topic: "Chores",         intensity_scale: 3,
      situation: "I asked about the trash a few times and it’s still there." },
    { user: paul, feeling: "Tired",     topic: "Social meter",  intensity_scale: 4,
      situation: "I don't like when I am obligated to go when make dinner plans with your friends. I don't have the energy or patience to entertain them every weekend" },
    { user: mai,  feeling: "Upset",   topic: "Work-life balance",      intensity_scale: 3,
      situation: "Late work nights make dinners together rare." }
  ].map { |h| h.merge(partnership: partnership) }
  upsert_grievances!(rows: grievances, partnership: partnership)
end
puts "== Done. Users: #{User.count}, Partnership: #{Partnership.count}, Checkins: #{Checkin.count}, Grievances: #{Grievance.count} =="