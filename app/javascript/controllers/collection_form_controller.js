import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["newCollection"]

  toggle(event) {
    this.newCollectionTarget.classList.toggle("hidden", !event.target.checked)
  }
}
