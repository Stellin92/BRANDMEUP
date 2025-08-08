# db/seeds/full_seed_cloudinary_activestorage.rb

puts "🌱 Seeding 24 users using ActiveStorage (with Cloudinary service)"

require "faker"
require 'set'

segments = ["dj", "entrepreneur", "athlete"]
genders = ["man", "woman"]
ethnicities = ["Black", "White", "Asian", "Latino", "Middle Eastern", "Mixed"]
outfits_per_user = 6
base_path = Rails.root.join("db/seeds/images")

24.times do |index|
  id = index + 1
  username = "user_#{id.to_s.rjust(2, '0')}"
  segment = segments[index % segments.length]
  gender = genders[index % genders.length]
  ethnicity = ethnicities[index % ethnicities.length]
  values = Faker::Lorem.words(number: 3).map(&:capitalize)
  bio = Faker::Quote.matz
  talent = Faker::Job.title

  user = User.find_or_create_by!(email: "#{username}@example.com") do |u|
    u.username = username
    u.password = "brandmeup123"
    u.bio = bio
    u.talent = talent
    u.values = values
  end

  profile_path = base_path.join("user_#{id.to_s.rjust(2, '0')}_profile.jpg")
  if File.exist?(profile_path) && !user.photo.attached?
    user.photo.attach(
      io: File.open(profile_path),
      filename: profile_path.basename.to_s
    )
  end

  # Create outfits

  user = User.create!(
  email: Faker::Internet.unique.email,
  password: "password",
  username: Faker::Internet.username,
  bio: Faker::Quote.most_interesting_man_in_the_world,
  values: ["authenticity", "style", "resilience"].sample(3),
  talent: ["dance", "boxing", "writing", "business"].sample
)

outfits_per_user.times do |j|
  outfit_id = j + 1
  outfit_path = base_path.join("user_#{id.to_s.rjust(2, '0')}_outfit_#{outfit_id}.jpg")

  outfit = user.outfits.create!(
    title: "Outfit ##{outfit_id}",
    description: "#{Faker::Commerce.brand} meets #{Faker::Color.color_name}",
    color_set: Array.new(4) { "#" + "%06x" % (rand * 0xffffff) },
    style: ["urban", "sporty", "edgy", "clean", "bold"].sample,
    goal: ["visibility", "connection", "inspiration", "credibility"].sample
  )

  if File.exist?(outfit_path)
    outfit.photo.attach(
      io: File.open(outfit_path),
      filename: outfit_path.basename.to_s
    )
  end

  # Add feedbacks
  rand(2..4).times do
    outfit.feedbacks.create!(
      comment: Faker::Quotes::Shakespeare.hamlet_quote,
      score: rand(3..5),
      user: User.order("RANDOM()").where.not(id: user.id).first
    )
  end
end

  # Create chat messages
users = User.all.to_a

# Suivi des couples déjà utilisés
created_pairs = Set.new

users.each do |user|
  # On génère 2 à 3 chats par user
  rand(2..3).times do
    partner = (users - [user]).sample

    # Identifiant unique de la paire, peu importe l'ordre
    pair_key = [user.id, partner.id].sort.join("-")

    # On passe si cette paire a déjà un chat
    next if created_pairs.include?(pair_key)

    # On crée le chat
    chat = Chat.create!(
      user: user,
      partner: partner
    )

    created_pairs << pair_key

    # Ajoute entre 2 et 5 messages
    rand(2..5).times do
      chat.messages.create!(
        user: [user, partner].sample,
        content: Faker::Quotes::Chiquito.joke
      )
    end
  end
end

puts "✅ Done seeding users and data."
