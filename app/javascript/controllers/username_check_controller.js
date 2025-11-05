import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "feedback"]

  connect() {
    this.debouncedCheck = this.debounce(this.check.bind(this), 300)
  }

  check() {
    const username = this.inputTarget.value
    fetch(`/users/check_username?username=${username}`)
      .then(response => response.text())
      .then(html => {
        this.feedbackTarget.innerHTML = html
      })
  }

  debounce(func, delay) {
    let timeout
    return (...args) => {
      clearTimeout(timeout)
      timeout = setTimeout(() => func(...args), delay)
    }
  }
}
