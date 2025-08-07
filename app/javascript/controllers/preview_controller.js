import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  update(event) {
    const input = event.target
    const preview = document.getElementById("photo-preview")

    if (input.files && input.files[0]) {
      const reader = new FileReader()
      reader.onload = e => preview.src = e.target.result
      reader.readAsDataURL(input.files[0])
    }
  }
}
