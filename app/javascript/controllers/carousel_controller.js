import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "controls"]

  connect() {
    // si le contrôleur est monté sur le track, on peut aussi trouver les boutons via dataset-controls
    this.track = this.hasTrackTarget ? this.trackTarget : this.element
  }

  next() { this.#scrollByCard(1) }
  prev() { this.#scrollByCard(-1) }

  #scrollByCard(direction = 1) {
    if (!this.track) return
    const card = this.track.querySelector(".testimonial")
    const gap = parseFloat(getComputedStyle(this.track).columnGap || getComputedStyle(this.track).gap || 16)
    const width = card ? card.getBoundingClientRect().width : 320
    const amount = (width + gap) * direction
    this.track.scrollBy({ left: amount, behavior: "smooth" })
  }
}
