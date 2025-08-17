import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { currentUserId: Number }
  connect() { this._markAll(); this._observe() }
  disconnect() { this.observer?.disconnect() }
  _markAll() {
    this.element.querySelectorAll(".msg:not([data-marked])")
      .forEach(el => this._mark(el))
  }
  _mark(el) {
    const senderId = el.getAttribute("data-sender-id")
    const mine = senderId && String(senderId) === String(this.currentUserIdValue)
    el.classList.add(mine ? "mine" : "theirs")
    el.setAttribute("data-marked", "1")
  }
  _observe() {
    this.observer = new MutationObserver(muts => muts.forEach(m =>
      m.addedNodes.forEach(node => {
        if (node.nodeType === 1 && node.classList.contains("msg")) this._mark(node)
      })
    ))
    this.observer.observe(this.element, { childList: true })
  }
}
