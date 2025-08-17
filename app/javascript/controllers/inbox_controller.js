// app/javascript/controllers/inbox_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "overlay"]

  connect() {
    this._openListener = () => this.open()
    window.addEventListener("inbox:open", this._openListener)
    this._onKeyDown = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this._onKeyDown)

    // Opens as soon as the turbo-frame is loaded and it's #inbox
    this._onFrameLoad = (e) => { if (e.target?.id === "inbox") this.open() }
    document.addEventListener("turbo:frame-load", this._onFrameLoad)
  }
  disconnect() {
    window.removeEventListener("inbox:open", this._openListener)
    document.removeEventListener("keydown", this._onKeyDown)
    document.removeEventListener("turbo:frame-load", this._onFrameLoad)
  }

  toggle(e) { e?.preventDefault(); this.drawerTarget.classList.toggle("is-open"); this._sync() }
  open()    { this.drawerTarget.classList.add("is-open");  this.overlayTarget.classList.add("is-visible") }
  close()   { this.drawerTarget.classList.remove("is-open"); this.overlayTarget.classList.remove("is-visible") }
  _sync()   { this.overlayTarget.classList.toggle("is-visible", this.drawerTarget.classList.contains("is-open")) }
}
