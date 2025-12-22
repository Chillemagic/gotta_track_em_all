import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  favourite(event) {
    console.log("Event params:", event.params)
    console.log("favouriteCurrent raw:", event.target.dataset.toggleFavouriteCurrentParam)


    const cardId = event.params.favouriteId
    const currentValue = event.params.favouriteCurrent
    const newValue = !currentValue

    // Update the DOM param so the next click reads the correct value
    event.target.dataset.toggleFavouriteCurrentParam = newValue.toString()

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(`/collection_cards/${cardId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      },
      body: JSON.stringify({
        collection_card: { favourite: newValue }
      })
    })
      .then(response => response.json())
      .then(data => console.log("Server updated:", data))
      .catch(error => console.error("PATCH request failed:", error))
  }
}
