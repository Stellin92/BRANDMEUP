# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails",        to: "turbo.min.js", preload: true
pin "@hotwired/stimulus",           to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading",   to: "stimulus-loading.js", preload: true

# ⬇️ indispensable si tu fais import "controllers"
pin "controllers", to: "controllers/index.js"

# ⬇️ charge tous tes controllers automatiquement
pin_all_from "app/javascript/controllers", under: "controllers"

# Bootstrap (garde tes chemins locaux OU colle ces CDN)
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.8/lib/index.js"
pin "bootstrap",      to: "https://ga.jspm.io/npm:bootstrap@5.3.3/dist/js/bootstrap.esm.js"
