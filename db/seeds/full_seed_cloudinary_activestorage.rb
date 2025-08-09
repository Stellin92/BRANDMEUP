# db/seeds/full_seed_cloudinary_activestorage.rb
# Requires:
# - Devise User (email/password)
# - ActiveStorage configured with Cloudinary service in storage.yml
# - Models: User has_many :outfits, :feedbacks, :messages, :chats
#           Outfit belongs_to :user, has_one_attached :photo, has_many :feedbacks
#           Feedback belongs_to :user, :outfit, columns: comment:string, score:integer(1..5)
#           Chat belongs_to :user, :partner (User), has_many :messages
#           Message belongs_to :user, :chat, content:string

require "faker"
require "securerandom"

puts "🌱 Seeding 24 users using ActiveStorage (Cloudinary service)…"

IMAGES_DIR = Rails.root.join("db/seeds/images")
SEGMENTS    = %w[dj entrepreneur athlete]
STYLES      = %w[urban sporty edgy clean bold]
GOALS       = %w[visibility connection inspiration credibility]
OUTFITS_PER_USER = 6

FEEDBACK_POSITIVE = [
  "Love the color balance and silhouette.",
  "Great energy—this look really pops!",
  "Clean lines and strong presence.",
  "The layering works perfectly here.",
  "Confident vibe, fits the brief nicely."
]
FEEDBACK_CONSTRUCTIVE = [
  "Nice base—try a bolder accent color.",
  "Consider a different shoe to refine proportions.",
  "Try a lighter outer layer to balance the palette.",
  "Maybe simplify accessories for a sharper focus."
]

# ---------- OPTIONAL CLEANUP (uncomment if you want a totally clean slate) ----------
puts "🧹 Cleaning chats/messages/feedbacks/outfits/users…"
Message.delete_all
Chat.delete_all
Feedback.delete_all
Outfit.delete_all
User.delete_all

def img_path_for(user_idx, kind, outfit_idx=nil)
  if kind == :profile
    IMAGES_DIR.join(format("user_%02d_profile.jpg", user_idx))
  else
    IMAGES_DIR.join(format("user_%02d_outfit_%d.jpg", user_idx, outfit_idx))
  end
end

def attach_if_present(record, path)
  return unless File.exist?(path)
  return if record.respond_to?(:photo) && record.photo.attached?
  record.photo.attach(io: File.open(path), filename: File.basename(path))
end

# ---------- Phase 1: Users (names, emails, profiles) ----------
users = []

24.times do |i|
  idx = i + 1

  human_name = Faker::Name.name # e.g., "Ava Carter"
  base_slug  = human_name.parameterize(separator: "_") # "ava_carter"
  username   = human_name                               # store human-readable in username
  email      = "#{base_slug}_#{format('%02d', idx)}@example.com" # unique & stable
  password   = "brandmeup123"

  user = User.find_or_initialize_by(email: email)
  if user.new_record?
    user.password = password
    user.username = username
    user.bio      = Faker::Quote.matz
    user.talent   = %w[DJ Entrepreneur Athlete].sample
    user.values   = Faker::Lorem.words(number: 3).map(&:capitalize)
    user.save!
    puts "✅ Created: #{email} (#{username})"
  else
    # Keep existing but ensure username present
    user.update!(username: username) unless user.username.present?
    puts "↩️  Reusing: #{email}"
  end

  profile_path = img_path_for(idx, :profile)
  attach_if_present(user, profile_path)
  users << user
end

# ---------- Phase 2: Outfits (titles, photos) + Feedbacks ----------
users.each_with_index do |user, i|
  idx = i + 1
  segment = SEGMENTS[(idx - 1) % SEGMENTS.size]

  # Rebuild outfits each run for consistency
  user.outfits.destroy_all

  OUTFITS_PER_USER.times do |j|
    outfit_idx  = j + 1
    style       = STYLES.sample
    title       = "#{segment.capitalize} look ##{outfit_idx} – #{style.capitalize}"
    description = "#{Faker::Commerce.brand} meets #{Faker::Color.color_name}"
    color_set   = Array.new(4) { "##{format('%06x', (rand * 0xffffff))}" }
    goal        = GOALS.sample

    outfit = user.outfits.create!(
      title: title,
      description: description,
      color_set: color_set,
      style: style,
      goal: goal,
      public: [true, false].sample
    )

    outfit_path = img_path_for(idx, :outfit, outfit_idx)
    attach_if_present(outfit, outfit_path)

    # Feedbacks on outfit (2–4), tied to BOTH user and outfit
    rand(2..4).times do
      positive = rand < 0.8
      comment  = positive ? FEEDBACK_POSITIVE.sample : FEEDBACK_CONSTRUCTIVE.sample
      score    = positive ? rand(4..5) : rand(2..4)
      Feedback.create!(
        user: user,
        outfit: outfit,
        score: score,
        comment: comment
      )
    end
  end
end

# ---------- Phase 3: Chats & Messages ----------
# Give each user at least 3 chats with unique partners
users.each do |user|
  # Remove user’s existing chats (optional). Comment out if you want to accumulate.
  user.chats.destroy_all

  partners = users.reject { |u| u.id == user.id }.sample(3)
  partners.each do |partner|
    chat = Chat.create!(user: user, partner: partner)

    # At least 3 messages, alternating speaker
    3.times do |m|
      speaker = (m.even? ? user : partner)
      Message.create!(
        chat: chat,
        user: speaker,
        content: [
          "Hey! Loving the latest look.",
          "What’s your goal with this outfit?",
          "Colors are strong—maybe try a lighter jacket.",
          "Fits the vibe perfectly for a club session.",
          "I’d swap the shoes—everything else is on point!"
        ].sample
      )
    end
  end
end

puts "✅ Done. Users: #{User.count}, Outfits: #{Outfit.count}, Feedbacks: #{Feedback.count}, Chats: #{Chat.count}, Messages: #{Message.count}"
