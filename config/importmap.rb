# Pin npm packages by running ./bin/importmap

# pin "application"
# pin "@hotwired/turbo-rails", to: "turbo.min.js"
# pin "@hotwired/stimulus", to: "stimulus.min.js"
# pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
# # pin "rails-ujs-wrapper", to: "rails-ujs-wrapper.js"
# pin_all_from "app/javascript/controllers", under: "controllers"


# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@tailwindcss/browser", to: "https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4/+esm"
pin "@tailwindplus/elements", to: "https://cdn.jsdelivr.net/npm/@tailwindplus/elements@1/+esm"
pin_all_from "app/javascript/controllers", under: "controllers"
