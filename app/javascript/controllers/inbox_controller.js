// app/javascript/controllers/inbox_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "overlay", "frame"]

  connect() { this.loaded = false }

  toggle(e) {
    e?.preventDefault()
    if (!this.loaded) this.load()
    this.drawerTarget.classList.toggle("is-open")
    this._sync()
  }

  open() {
    if (!this.loaded) this.load()
    this.drawerTarget.classList.add("is-open")
    this.overlayTarget.classList.add("is-visible")
  }

  close() {
    this.drawerTarget.classList.remove("is-open")
    this.overlayTarget.classList.remove("is-visible")
  }

  load() {
    if (!this.hasFrameTarget) return
    const url = this.frameTarget.getAttribute("data-src")
    const hasSrc = this.frameTarget.getAttribute("src")
    if (url && !hasSrc) this.frameTarget.setAttribute("src", url) // charge 1 seule fois
    this.loaded = true
  }

  _sync() {
    this.overlayTarget.classList.toggle(
      "is-visible",
      this.drawerTarget.classList.contains("is-open")
    )
  }
}
