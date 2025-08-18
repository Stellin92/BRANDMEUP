import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    // éviter de déclencher si on clique un lien sur la face arrière
    const target = event.target
    if (target.closest('a')) return
    this.element.classList.toggle("is-flipped")
  }
}
