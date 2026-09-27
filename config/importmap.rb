# Pin npm packages by running ./bin/importmap

# pin "application"
# pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
# pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
# # pin "rails-ujs-wrapper", to: "rails-ujs-wrapper.js"
# pin_all_from "app/javascript/controllers", under: "controllers"


# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "channels", to: "channels/index.js"
pin "@tailwindplus/elements", to: "https://cdn.jsdelivr.net/npm/@tailwindplus/elements@1/+esm"
pin "photoswipe", to: "https://ga.jspm.io/npm:photoswipe@5.4.4/dist/photoswipe.esm.js"
pin "embla-carousel", to: "https://cdn.jsdelivr.net/npm/embla-carousel/embla-carousel.esm.js"
pin "embla-carousel-wheel-gestures", to: "https://cdn.jsdelivr.net/npm/embla-carousel-wheel-gestures@latest/+esm"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@stimulus-components/dialog", to: "@stimulus-components--dialog.js" # @1.0.1
