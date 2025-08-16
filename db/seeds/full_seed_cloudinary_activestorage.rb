# db/seeds/full_seed_cloudinary_activestorage.rb
# Rails 7+, ActiveStorage (service Cloudinary)
# Modèles:
#   User has_many :outfits, :feedbacks
#   Outfit belongs_to :user, has_one_attached :photo, has_many :feedbacks
#   Feedback belongs_to :user, :outfit (comment:string, score:integer 1..5)
#
# Spécifications:
# - AUCUN chat/message
# - Feedbacks par d'autres users (2..4 / outfit)
# - Images: si un fichier local existe => on l'attache
#           sinon => on attache via URL Cloudinary (public_id déjà présent)
#
# Pré-requis:
# - ENV["CLOUDINARY_CLOUD_NAME"] (ou configure CLOUDINARY_URL)
# - Dossier local optionnel: db/seeds/images/
#     - user_01_profile.jpg
#     - user_01_outfit_1.jpg ... user_01_outfit_6.jpg
# - Convention Cloudinary (modifiable plus bas):
#     profiles: "brandmeup/users/user_01/profile"
#     outfits : "brandmeup/outfits/user_01_1" ... _6

require "faker"
require "open-uri"   # pour URI.open
require "securerandom"

puts "🌱 Reseed BrandMeUp (fallback local → Cloudinary)…"

# ---------- CONFIG ----------
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

# Map public_id Cloudinary par défaut (ADAPTE si tu as une autre convention)
CLOUD_NAME = ENV["CLOUDINARY_CLOUD_NAME"] || ENV["CLOUDINARY_CLOUD_NAME".downcase]
raise "Missing ENV CLOUDINARY_CLOUD_NAME" unless CLOUD_NAME.present?

CLOUDINARY_PUBLIC_IDS = (1..24).each_with_object({}) do |idx, h|
  user_key = format("user_%02d", idx)
  h[user_key] = {
    profile: "brandmeup/users/#{user_key}/profile",
    outfits: (1..OUTFITS_PER_USER).map { |k| "brandmeup/outfits/#{user_key}_#{k}" }
  }
end

# ---------- HELPERS ----------
def img_path_for(user_idx, kind, outfit_idx = nil)
  if kind == :profile
    IMAGES_DIR.join(format("user_%02d_profile.jpg", user_idx))
  else
    IMAGES_DIR.join(format("user_%02d_outfit_%d.jpg", user_idx, outfit_idx))
  end
end

def cloudinary_public_id_for(user_idx, kind, outfit_idx = nil)
  key = format("user_%02d", user_idx)
  if kind == :profile
    CLOUDINARY_PUBLIC_IDS.fetch(key)[:profile]
  else
    CLOUDINARY_PUBLIC_IDS.fetch(key)[:outfits][outfit_idx - 1]
  end
end

def cloudinary_url(public_id)
  # URL versionnée automatique côté Cloudinary : idéal pour le cache busting
  "https://res.cloudinary.com/#{CLOUD_NAME}/image/upload/#{public_id}"
end

def attach_local_or_cloudinary!(record, user_idx:, kind:, outfit_idx: nil)
  path = img_path_for(user_idx, kind, outfit_idx)
  if File.exist?(path)
    record.photo.attach(io: File.open(path), filename: File.basename(path))
  else
    public_id = cloudinary_public_id_for(user_idx, kind, outfit_idx)
    url       = cloudinary_url(public_id)
    filename  = if kind == :profile
                  "user_#{format('%02d', user_idx)}_profile.jpg"
                else
                  "user_#{format('%02d', user_idx)}_outfit_#{outfit_idx}.jpg"
                end
    record.photo.attach(
      io: URI.open(url),
      filename: filename,
      content_type: "image/jpeg"
    )
  end
end

def rand_hex_color
  "##{format('%06x', (rand * 0xffffff))}"
end

# ---------- SEED ----------
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

    # Attach profile (local si présent, sinon Cloudinary)
    begin
      attach_local_or_cloudinary!(user, user_idx: idx, kind: :profile)
    rescue => e
      warn "⚠️ Profile image missing for user_#{format('%02d', idx)} (#{e.class}: #{e.message}) — skipping."
    end
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

      begin
        attach_local_or_cloudinary!(outfit, user_idx: idx, kind: :outfit, outfit_idx: outfit_idx)
      rescue => e
        warn "⚠️ Outfit image missing for user_#{format('%02d', idx)} [##{outfit_idx}] (#{e.class}: #{e.message}) — skipping."
      end

      # Feedbacks (2..4) par d'autres users (jamais le owner)
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
