// app/javascript/controllers/auto_scroll_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() { this._scroll(); this._observe() }
  disconnect() { this.observer?.disconnect() }
  _observe() {
    this.observer = new MutationObserver(() => this._scroll())
    this.observer.observe(this.element, { childList: true })
  }
  _scroll() { this.element.scrollTop = this.element.scrollHeight }
}
