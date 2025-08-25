# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Clearing existing data..."
Partnership.destroy_all
User.destroy_all

puts "Creating users..."
User.create({
  username: "Bob",
  email: "bob@email.com",
  password: "password",
  personality: "Melancholic",
  love_language: "Words of Affirmation",
  pronouns: "He/Him",
  hobbies: "Fishing",
  birthday: Date.new(1983, 4, 10)
})

User.create({
  username: "Karen",
  email: "karen@email.com",
  password: "password",
  personality: "Sanguine",
  love_language: "Physical Touch",
  pronouns: "She/Her",
  hobbies: "Drinking, Shopping",
  birthday: Date.new(1989, 6, 23)
})

puts "Creating the partnership"
Partnership.create({
  user_one: User.all[0],
  user_two: User.all[1]
})

puts "All Done!"
