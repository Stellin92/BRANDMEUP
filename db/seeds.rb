# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Cleaning up database..."
Message.destroy_all
Chat.destroy_all
Outfit.destroy_all
User.destroy_all

puts "Creating users..."
users = []

users_data = [
  { username: "ymurillo",  bio: "Never stop exploring.", talent: "Designer",  values: ["eat", "once", "pattern"] },
  { username: "othomas",   bio: "Passionate about sound.", talent: "Marketer", values: ["class", "add", "why"] },
  { username: "pmurray",   bio: "Dream big. Act bigger.", talent: "Designer",  values: ["treatment", "close", "evening"] },
  { username: "nguyenshane", bio: "Shaping ideas into form.", talent: "Marketer", values: ["respond", "material", "memory"] },
  { username: "crosbyjennifer", bio: "Strong mind, strong body.", talent: "Athlete", values: ["deep", "time", "choose"] },
  { username: "carrolljessica", bio: "Life is a canvas.", talent: "DJ", values: ["free", "energy", "flow"] }
]

users_data.each do |data|
  users << User.create!(
    username: data[:username],
    bio: data[:bio],
    talent: data[:talent],
    values: data[:values],
    email: "#{data[:username]}@example.com",
    password: "password"
  )
end

puts "Creating chats..."
chat_pairs = users.combination(2).to_a.sample(4)
chats = chat_pairs.map do |user1, user2|
  Chat.create!(user: user1, partner: user2)
end

puts "Creating messages..."
chats.each do |chat|
  rand(3..6).times do
    sender = [chat.user, chat.partner].sample
    Message.create!(
      chat: chat,
      user: sender,
      content: Faker::Lorem.sentence(word_count: 8)
    )
  end
end

puts "Creating outfits..."
styles = ["Casual", "Avant-Garde", "Sporty", "Minimalist"]
goals = ["Confidence", "Comfort", "Impact", "Performance"]

6.times do
  user = users.sample
  Outfit.create!(
    title: "#{Faker::Emotion.adjective.capitalize} Vibes",
    description: Faker::Lorem.sentence,
    color_set: Array.new(4) { Faker::Color.color_name },
    items_list: Array.new(4) { Faker::Commerce.product_name },
    style: styles.sample,
    goal: goals.sample,
    outfit_image_url: Faker::LoremFlickr.image,
    user: user
  )
end

puts "✅ Seeds generated successfully!"
