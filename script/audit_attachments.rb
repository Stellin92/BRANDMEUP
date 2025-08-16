# script/audit_attachments.rb
# Audite les attachments Active Storage (profil + 6 outfits)
require "active_storage"
include Rails.application.routes.url_helpers
Rails.application.routes.default_url_options[:host] = "www.brandmeup.net"

users_total   = User.count
ok_profiles   = 0
ok_outfits    = 0
missing_prof  = []
missing_out   = []

puts "=== Audit attachments (#{users_total} users) ==="
User.order(:id).find_each do |u|
  prof_ok = u.photo.attached?
  ok_profiles += 1 if prof_ok
  missing_prof << u.id unless prof_ok

  outfits = u.outfits.order(:id)
  missing_for_user = []
  outfits.each_with_index do |o, idx|
    if o.photo.attached?
      ok_outfits += 1
    else
      missing_for_user << (idx + 1)
      missing_out << [u.id, o.id]
    end
  end

  puts "User ##{u.id} (#{u.username})  profile: #{prof_ok ? 'OK' : 'MISSING'} | outfits: #{outfits.size} | missing idx: #{missing_for_user.join(', ')}"
end

puts "=== Summary ==="
puts "Profiles OK: #{ok_profiles}/#{users_total}"
puts "Outfits photos OK: #{ok_outfits}/#{Outfit.count}"
puts "Missing profiles for users: #{missing_prof.join(', ')}" if missing_prof.any?
puts "Missing outfits: #{missing_out.size} (pairs [user_id, outfit_id])"
