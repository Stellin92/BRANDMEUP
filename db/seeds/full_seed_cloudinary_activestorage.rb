# Rails 7+, ActiveStorage service: Cloudinary
# Modèles:
#   User has_many :outfits, :feedbacks
#   Outfit belongs_to :user, has_one_attached :photo, has_many :feedbacks
#   Feedback belongs_to :user, :outfit (comment:string, score:integer 1..5)
# Spécifs:
# - PAS de chats/messages
# - Feedbacks par d'autres users (2..4 / outfit)
# - Images locales => ActiveStorage les upload vers Cloudinary

require "faker"
require "securerandom"

puts "🌱 Reseed BrandMeUp (local files -> Cloudinary via ActiveStorage)…"

IMAGES_DIR        = Rails.root.join("db/seeds/images")
SEGMENTS          = %w[dj entrepreneur athlete].freeze
STYLES            = %w[urban sporty edgy clean bold].freeze
GOALS             = %w[visibility connection inspiration credibility].freeze
OUTFITS_PER_USER  = 6

FEEDBACK_POSITIVE = [
  "Love the color balance and silhouette.",
  "Great energy—this look really pops!",
  "Clean lines and strong presence.",
  "The layering works perfectly here.",
  "Confident vibe, fits the brief nicely."
].freeze
FEEDBACK_CONSTRUCTIVE = [
  "Nice base—try a bolder accent color.",
  "Consider a different shoe to refine proportions.",
  "Try a lighter outer layer to balance the palette.",
  "Maybe simplify accessories for a sharper focus."
].freeze

def img_path_for(user_idx, kind, outfit_idx = nil)
  if kind == :profile
    IMAGES_DIR.join(format("user_%02d_profile.jpg", user_idx))
  else
    IMAGES_DIR.join(format("user_%02d_outfit_%d.jpg", user_idx, outfit_idx))
  end
end

def attach_local!(record, path)
  unless File.exist?(path)
    warn "⚠️ Image missing: #{path} — skipping attach."
    return
  end
  record.photo.attach(
    io: File.open(path),
    filename: File.basename(path),
    content_type: "image/jpeg"
  )
end

def rand_hex_color
  "##{format('%06x', (rand * 0xffffff))}"
end

ActiveRecord::Base.transaction do
  puts "🧹 Cleaning Feedbacks/Outfits/Users + ActiveStorage…"
  Feedback.delete_all
  Outfit.delete_all
  ActiveStorage::Attachment.delete_all
  ActiveStorage::Blob.delete_all
  User.delete_all

  users = []

  puts "👤 Creating 24 users…"
  24.times do |i|
    idx        = i + 1
    human_name = Faker::Name.name
    base_slug  = human_name.parameterize(separator: "_")
    email      = "#{base_slug}_#{format('%02d', idx)}@example.com"
    password   = "brandmeup123"

    user = User.create!(
      email: email,
      password: password,
      username: human_name,
      bio: Faker::Quote.matz,
      talent: %w[DJ Entrepreneur Athlete].sample,
      values: Faker::Lorem.words(number: 3).map(&:capitalize)
    )
    users << user

    attach_local!(user, img_path_for(idx, :profile))
  end

  puts "🧥 Creating outfits + feedbacks…"
  users.each_with_index do |owner, i|
    idx     = i + 1
    segment = SEGMENTS[(idx - 1) % SEGMENTS.size]

    OUTFITS_PER_USER.times do |j|
      outfit_idx  = j + 1
      style       = STYLES.sample
      title       = "#{segment.capitalize} look ##{outfit_idx} – #{style.capitalize}"
      description = "#{Faker::Commerce.brand} meets #{Faker::Color.color_name}"
      colors      = Array.new(4) { rand_hex_color }
      goal        = GOALS.sample

      outfit = owner.outfits.create!(
        title: title,
        description: description,
        color_set: colors,
        style: style,
        goal: goal,
        public: [true, false].sample
      )

      attach_local!(outfit, img_path_for(idx, :outfit, outfit_idx))

      # Feedbacks (2..4) par d'autres users
      feedback_authors = (users - [owner]).sample(rand(2..4))
      feedback_authors.each do |_author|
        positive = rand < 0.75
        comment  = positive ? FEEDBACK_POSITIVE.sample : FEEDBACK_CONSTRUCTIVE.sample
        score    = positive ? rand(4..5) : rand(2..4)
        Feedback.create!(
          user: _author,
          outfit: outfit,
          score: score,
          comment: comment
        )
      end
    end
  end
end

puts "✅ Done. Users: #{User.count}, Outfits: #{Outfit.count}, Feedbacks: #{Feedback.count}"
