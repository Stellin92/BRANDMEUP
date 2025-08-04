# Pin npm packages by running ./bin/importmap

pin "application"

# Hotwired: Stimulus
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Bootstrap + Popper

# Hotwired: Turbo
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js", integrity: "sha384-v7FP4RPRQwLyHEIKPJFJ+sv3t0A31DdzGe25ym5ivgGf0YRQOe4KoWi+jfhQ7gXv" # @8.0.16
pin "@hotwired/turbo", to: "@hotwired--turbo.js", integrity: "sha384-Ar5BI7e7pT8hROa/8lS1X1ANGto4Pa7UJb06l16NbEqGKD/CCab3ZTrtWi18TVam" # @8.0.13

# ActionCable
pin "@rails/actioncable", to: "@rails--actioncable.js", integrity: "sha384-J9kCXP+j3uFXQw6/pfAdLmqYNZ019ggd096Lebw+1crESHJvLM3wRMOF+il4u0Gp" # @8.0.200
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js", integrity: "sha384-oGoEWlBEWjlcDjT5Z8LqSP9tQQ/9dGM6dwAD11vwM5QKnIb2rSxef18v6MUS0BUR" # @8.0.200
pin "bootstrap", integrity: "sha384-Hea0Yk7N2rQhmxzzIGikclw/jBEhpCDFFXi+rlgF1qZtC7eAazBGapuqKzAe6yXQ" # @5.3.7
pin "@popperjs/core", to: "@popperjs--core.js", integrity: "sha384-bfekMOfeUlr1dHZfNaAFiuuOeD7r+Qh45AQ2HHJY7EAAI4QGJ6qx1Qq9gsbvS+60" # @2.11.8
