# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
MOODS = ["Happy", "Fine", "Tired", "Sad", "Upset", "Anxious"]
MY_DAY = ["Good", "Bad"]

MOOD_COMMENTS = {
  "Happy" => [
    "I feel so grateful today!",
    "Everything seems to go my way.",
    "The sunshine made my morning perfect."
  ],

  "Fine" => [
    "Nothing special today, just an okay day.",
    "I feel fine, not great but not bad either.",
    "Everything's pretty normal, can't complain much."
  ],

  "Tired" => [
    "I barely slept last night...",
    "Work drained all my energy.",
    "Need coffee, ASAP."
  ],

  "Sad" => [
    "Feeling low, I just want to be alone today.",
    "It's been a tough day, I can't shake this sadness.",
    "I miss how things used to be, nothing feels right."
  ],

  "Upset" => [
    "My clothes' brand were fake.",
    "I am sick of my job.",
    "We are spending too much money."
  ],
  "Anxious" => [
    "Deadlines are killing me.",
    "Too many things happening at once.",
    "I can't catch a break."
  ]
}

puts "Clearing existing data..."
Partnership.destroy_all
User.destroy_all

puts "Creating users..."
User.create(
  username: "Bob",
  email: "bob@email.com",
  password: "password",
  personality: "Melancholic",
  love_language: "Words of Affirmation",
  pronouns: "He/Him",
  hobbies: "Fishing",
  birthday: Date.new(1983, 4, 10)
)

User.create(
  username: "Karen",
  email: "karen@email.com",
  password: "password",
  personality: "Sanguine",
  love_language: "Physical Touch",
  pronouns: "She/Her",
  hobbies: "Drinking, Shopping",
  birthday: Date.new(1989, 6, 23)
)

puts "Creating the partnership"
Partnership.create(
  user_one: User.all[0],
  user_two: User.all[1]
)

puts "Creating Checkins"

(1..5).each do |num|
  date = Date.today - num.day
  one_mood = MOODS.sample
  two_mood = MOODS.sample

  Checkin.create!(
    mood: one_mood,
    my_day: MY_DAY.sample,
    discuss: [true, false].sample,
    comment: MOOD_COMMENTS[one_mood].sample,
    created_at: date,
    user: User.all[0],
    partnership: Partnership.all.first,
    nudge: DateTime.now + 2.hours
    )

  Checkin.create!(
    mood: two_mood,
    my_day: MY_DAY.sample,
    discuss: [true, false].sample,
    comment: MOOD_COMMENTS[two_mood].sample,
    created_at: date,
    user: User.all[1],
    partnership: Partnership.all.first,
    nudge: DateTime.now + 2.hours
    )
  end
# Checkin.create(
#   mood: "Tired",
#   my_day: "Bad",
#   discuss: false,
#   comment: "I am sick of my job.",
#   created_at: DateTime.now - 2.days,
#   user: User.all[0],
#   partnership: Partnership.all.first,
#   nudge: DateTime.now + 2.hours
#   )

# Checkin.create!(
#   mood: "Upset",
#   my_day: "Bad",
#   discuss: false,
#   comment: "We are spending too much money",
#   created_at: DateTime.now - 1.days,
#   user: User.all[0],
#   partnership: Partnership.all.first,
#   nudge: DateTime.now + 2.hours
#   )

puts "Creating Grievances"

Grievance.create!(
  user: User.all.sample,
  feeling: "Upset",
  topic: "Laundry",
  intensity_scale: 3,
  partnership: Partnership.all.first,
  situation: "Why do I always end up folding the laundry? It feels like you never notice how tired I am."
)

Grievance.create!(
  user: User.all.sample,
  feeling: "Sad",
  topic: "Communication",
  intensity_scale: 4,
  partnership: Partnership.all.first,
  situation: "I feel like we haven't really talked in days, and it makes me lonely."
)

Grievance.create!(
  user: User.all.sample,
  feeling: "Anxious",
  topic: "Money",
  intensity_scale: 5,
  partnership: Partnership.all.first,
  situation: "You keep spending without telling me, and I feel like I'm the only one worrying about our budget."
)

Grievance.create!(
  user: User.all.sample,
  feeling: "Sad",
  topic: "Attention",
  intensity_scale: 2,
  partnership: Partnership.all.first,
  situation: "When we go out, you're always on your phone. It makes me feel invisible."
)

Grievance.create!(
  user: User.all.sample,
  feeling: "Tired",
  topic: "Chores",
  intensity_scale: 3,
  partnership: Partnership.all.first,
  situation: "I asked you three times to take out the trash, and it's still sitting there. It makes me feel ignored."
)

Grievance.create!(
  user: User.all.sample,
  feeling: "Sad",
  topic: "Time together",
  intensity_scale: 4,
  partnership: Partnership.all.first,
  situation: "We keep canceling our plans, and I feel like spending time together isn't a priority anymore."
)

Grievance.create!(
  user: User.all.sample,
  feeling: "Tired",
  topic: "Cleanliness",
  intensity_scale: 3,
  partnership: Partnership.all.first,
  situation: "The sink is full of dirty dishes again. It feels like I'm the only one who cares about keeping things tidy."
)

Grievance.create!(
  user: User.all.sample,
  feeling: "Sad",
  topic: "Affection",
  intensity_scale: 4,
  partnership: Partnership.all.first,
  situation: "You don't hug or kiss me like you used to, and it makes me wonder if something's wrong."
)

Grievance.create!(
  user: User.all.sample,
  feeling: "Tired",
  topic: "Responsibilities",
  intensity_scale: 5,
  partnership: Partnership.all.first,
  situation: "I'm juggling work and home tasks, and I feel like I'm doing everything by myself."
)

Grievance.create!(
  user: User.all.sample,
  feeling: "Upset",
  topic: "Work-life balance",
  intensity_scale: 3,
  partnership: Partnership.all.first,
  situation: "You're always working late, and I miss having dinner together. I feel like we're growing apart."
)

puts "All done!"
