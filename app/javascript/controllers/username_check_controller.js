import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "feedback"]

  connect() {
    // Create debounced function once and bind it
    this.debouncedCheckFn = this.debounce(() => this.check(), 300)
    this.inputTarget.addEventListener("input", this.debouncedCheckFn)
  }

  check() {

    const username = this.inputTarget.value
    fetch(`/check_username?username=${encodeURIComponent(username)}`)
      .then(response => response.json())
      .then(data => {
        this.feedbackTarget.textContent = data.available
          ? "✅ Username is available"
          : "❌ Username is taken"
      })
  }

  debounce(func, wait) {
    let timeout
    return  (...args) => {
      clearTimeout(timeout)
      timeout = setTimeout(() => func.apply(this, args), wait)
    }
  }
}
