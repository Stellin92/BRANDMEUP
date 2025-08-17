# script/repair_attachments_from_local.rb
# Réattache les images manquantes depuis db/seeds/images
IMAGES_DIR = Rails.root.join("db/seeds/images")

def img_path_for(user_idx, kind, outfit_idx = nil)
  if kind == :profile
    IMAGES_DIR.join(format("user_%02d_profile.jpg", user_idx))
  else
    IMAGES_DIR.join(format("user_%02d_outfit_%d.jpg", user_idx, outfit_idx))
  end
end

def attach_local!(record, path)
  return unless File.exist?(path)
  record.photo.attach(
    io: File.open(path),
    filename: File.basename(path),
    content_type: "image/jpeg"
  )
end

fixed_profiles = 0
fixed_outfits  = 0

User.order(:id).find_each.with_index(1) do |u, idx|
  unless u.photo.attached?
    pth = img_path_for(idx, :profile)
    if File.exist?(pth)
      attach_local!(u, pth)
      fixed_profiles += 1
      puts "Attached profile for user ##{u.id} from #{pth}"
    else
      puts "Missing local profile for user ##{u.id} (#{pth})"
    end
  end

  # On suppose 6 outfits par user, indexés 1..6
  u.outfits.order(:id).each_with_index do |o, j|
    next if o.photo.attached?
    pth = img_path_for(idx, :outfit, j + 1)
    if File.exist?(pth)
      attach_local!(o, pth)
      fixed_outfits += 1
      puts "Attached outfit ##{o.id} (user ##{u.id}) from #{pth}"
    else
      puts "Missing local outfit image for outfit ##{o.id} (#{pth})"
    end
  end
end

puts "Repaired profiles: #{fixed_profiles}"
puts "Repaired outfits:  #{fixed_outfits}"
