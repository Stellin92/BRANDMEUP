# db/seeds/full_seed_cloudinary_activestorage.rb
# Rails >= 7, ActiveStorage configuré avec Cloudinary
# Modèles attendus :
# - User has_many :outfits, :feedbacks
# - Outfit belongs_to :user, has_one_attached :photo, has_many :feedbacks
# - Feedback belongs_to :user, :outfit (comment:string, score:integer 1..5)
#
# Spécificités demandées :
# - Images déjà sur Cloudinary -> on ATTACHE via URL Cloudinary (pas d’upload local)
# - On efface l’existant (users/outfits/feedbacks)
# - PAS de chats/messages
# - Feedbacks par d’autres users (2..4) par outfit

require "faker"
require "open-uri" # pour URI.open
require "securerandom"

puts "🌱 Reseed BrandMeUp (Cloudinary + ActiveStorage)…"

# ---------- CONFIG ----------
SEGMENTS    = %w[dj entrepreneur athlete].freeze
STYLES      = %w[urban sporty edgy clean bold].freeze
GOALS       = %w[visibility connection inspiration credibility].freeze
OUTFITS_PER_USER = 6

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

# IMPORTANT : indique ici les public_id Cloudinary déjà existants pour éviter tout ré-upload.
# Convention conseillée :
#   profiles:  "brandmeup/users/user_01/profile"
#   outfits :  "brandmeup/outfits/user_01_1", "brandmeup/outfits/user_01_2", …
#
# Remplis/ajuste selon TES public_id réels.
CLOUDINARY_PUBLIC_IDS = (1..24).each_with_object({}) do |idx, h|
  user_key = format("user_%02d", idx)
  h[user_key] = {
    profile: "brandmeup/users/#{user_key}/profile",
    outfits: (1..OUTFITS_PER_USER).map { |k| "brandmeup/outfits/#{user_key}_#{k}" }
  }
end

def cloudinary_url(public_id)
  # URL directe du fichier original.
  # Si tu veux une transformation (ex: format jpg), tu peux utiliser Cloudinary::Utils.cloudinary_url(public_id, fetch_format: "jpg")
  # mais l’URL simple marche généralement pour attacher via ActiveStorage.
  "https://res.cloudinary.com/#{ENV.fetch('CLOUDINARY_CLOUD_NAME')}/image/upload/#{public_id}"
end

def attach_cloudinary_image!(record, public_id, filename: nil, content_type: "image/jpeg")
  url = cloudinary_url(public_id)
  io  = URI.open(url)
  record.photo.attach(
    io: io,
    filename: filename || "#{public_id.split('/').last}.jpg",
    content_type: content_type
  )
end

def rand_hex_color
  "##{format('%06x', (rand * 0xffffff))}"
end

ActiveRecord::Base.transaction do
  puts "🧹 Cleaning Feedbacks/Outfits/Users…"
  Feedback.delete_all
  Outfit.delete_all
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

    # Attach profile from Cloudinary
    key = format("user_%02d", idx)
    begin
      attach_cloudinary_image!(user, CLOUDINARY_PUBLIC_IDS.fetch(key)[:profile],
                               filename: "#{key}_profile.jpg")
    rescue => e
      warn "⚠️ Profile image missing for #{key} (#{e.class}: #{e.message}) — skipping."
    end
  end

  puts "🧥 Creating outfits + feedbacks…"
  users.each_with_index do |owner, i|
    idx     = i + 1
    segment = SEGMENTS[(idx - 1) % SEGMENTS.size]
    key     = format("user_%02d", idx)
    outfit_ids = CLOUDINARY_PUBLIC_IDS.fetch(key)[:outfits]

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

      # Attach outfit image from Cloudinary
      begin
        attach_cloudinary_image!(outfit, outfit_ids[j], filename: "#{key}_outfit_#{outfit_idx}.jpg")
      rescue => e
        warn "⚠️ Outfit image missing for #{key} [##{outfit_idx}] (#{e.class}: #{e.message}) — skipping."
      end

      # === Feedbacks (2..4) par d'autres utilisateurs (pas l’owner) ===
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
