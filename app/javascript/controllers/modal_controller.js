import { Controller } from "@hotwired/stimulus"

// Gère l'ouverture/fermeture du modal avec un turbo-frame
export default class extends Controller {
  static targets = ["overlay", "frame"]

  connect() {
    this._onFrameLoad = (e) => {
      const frame = e.target
      if (frame.id === "outfit_modal") {
        // s'il y a du contenu, on ouvre
        if (frame.innerHTML.trim() !== "") this.open()
      }
    }
    document.addEventListener("turbo:frame-load", this._onFrameLoad)

    // fermer avec "Escape"
    this._onKey = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this._onKey)
  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this._onFrameLoad)
    document.removeEventListener("keydown", this._onKey)
  }

  open() {
    this.overlayTarget.hidden = false
    document.body.style.overflow = "hidden"
  }

  close() {
    // vide le frame pour le cacher
    this.frameTarget.innerHTML = ""
    this.overlayTarget.hidden = true
    document.body.style.overflow = ""
  }

  backdrop(e) {
    // ferme si on clique en dehors du panel
    if (e.target === this.overlayTarget) this.close()
  }
}
