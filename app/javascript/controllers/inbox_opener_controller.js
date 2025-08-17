// app/javascript/controllers/inbox_opener_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() { window.dispatchEvent(new CustomEvent("inbox:open")) }
}
