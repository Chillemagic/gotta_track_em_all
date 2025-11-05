import "@rails/ujs"

const Rails = window.Rails
if (Rails && !Rails.__started) {
  Rails.start()
  Rails.__started = true
  console.log("Rails UJS started")
}
